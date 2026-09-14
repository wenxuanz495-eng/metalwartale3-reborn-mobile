package com.superalloy.sasave;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Base64;
import com.adobe.fre.FREByteArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import org.json.JSONObject;

public final class SasaveContext extends FREContext {
    private static final int MAX_ARCHIVE_BYTES = 8 * 1024 * 1024;
    private static final int MAX_ENTRY_BYTES = 4 * 1024 * 1024;

    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
        functions.put("consumeIncoming", new ConsumeIncoming());
        functions.put("shareSave", new ShareSave());
        return functions;
    }

    public void dispose() {}

    private final class ConsumeIncoming implements FREFunction {
        public FREObject call(FREContext context, FREObject[] args) {
            try {
                Activity activity = getActivity();
                Intent intent = activity.getIntent();
                Uri uri = incomingUri(intent);
                if (uri == null) return stringObject(result("none", "", null));
                InputStream incoming = activity.getContentResolver().openInputStream(uri);
                byte[] archive = readAll(incoming, MAX_ARCHIVE_BYTES);
                incoming.close();
                JSONObject parsed = parseArchive(archive);
                File cacheFile = new File(activity.getCacheDir(), "incoming-superalloy-save.bin");
                FileOutputStream output = new FileOutputStream(cacheFile);
                output.write(Base64.decode(parsed.remove("saveBase64").toString(), Base64.DEFAULT));
                output.close();
                parsed.put("status", "ok");
                parsed.put("cachePath", cacheFile.getAbsolutePath());
                activity.setIntent(new Intent());
                return stringObject(parsed.toString());
            } catch (Throwable error) {
                return stringObject(result("error", safeMessage(error), null));
            }
        }
    }

    private final class ShareSave implements FREFunction {
        public FREObject call(FREContext context, FREObject[] args) {
            try {
                FREByteArray source = (FREByteArray) args[0];
                source.acquire();
                ByteBuffer buffer = source.getBytes();
                byte[] saveBytes = new byte[(int) source.getLength()];
                buffer.get(saveBytes);
                source.release();
                JSONObject manifest = new JSONObject(args[1].getAsString());
                manifest.put("payloadSha256", sha256(saveBytes));
                String fileName = cleanFileName(args[2].getAsString());
                Activity activity = getActivity();
                File directory = new File(activity.getCacheDir(), "sasave_exports");
                if (!directory.exists() && !directory.mkdirs()) throw new Exception("无法建立导出缓存目录");
                File archive = new File(directory, fileName);
                writeArchive(archive, manifest.toString().getBytes("UTF-8"), saveBytes);
                Uri shareUri = Uri.parse("content://" + activity.getPackageName() + ".sasave/" + Uri.encode(fileName));
                Intent send = new Intent(Intent.ACTION_SEND);
                send.setType("application/x-sasave");
                send.putExtra(Intent.EXTRA_STREAM, shareUri);
                send.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                activity.startActivity(Intent.createChooser(send, "分享超合金战记存档"));
                return stringObject(result("ok", archive.getAbsolutePath(), null));
            } catch (Throwable error) {
                return stringObject(result("error", safeMessage(error), null));
            }
        }
    }

    private static Uri incomingUri(Intent intent) {
        if (intent == null) return null;
        if (Intent.ACTION_SEND.equals(intent.getAction())) {
            Object stream = intent.getParcelableExtra(Intent.EXTRA_STREAM);
            return stream instanceof Uri ? (Uri) stream : null;
        }
        if (Intent.ACTION_VIEW.equals(intent.getAction())) return intent.getData();
        return null;
    }

    private static JSONObject parseArchive(byte[] archive) throws Exception {
        byte[] manifestBytes = null;
        byte[] saveBytes = null;
        int entries = 0;
        ZipInputStream zip = new ZipInputStream(new ByteArrayInputStream(archive));
        ZipEntry entry;
        while ((entry = zip.getNextEntry()) != null) {
            entries++;
            String name = entry.getName();
            if (entry.isDirectory() || name.indexOf('/') >= 0 || name.indexOf('\\') >= 0 || name.indexOf("..") >= 0) {
                throw new Exception("存档压缩包包含非法路径");
            }
            byte[] data = readAll(zip, MAX_ENTRY_BYTES);
            if ("manifest.json".equals(name)) manifestBytes = data;
            else if ("save.bin".equals(name)) saveBytes = data;
            else throw new Exception("存档压缩包包含非本游戏文件");
            zip.closeEntry();
        }
        zip.close();
        if (entries != 2 || manifestBytes == null || saveBytes == null) throw new Exception("不是有效的本游戏存档包");
        JSONObject manifest = new JSONObject(new String(manifestBytes, "UTF-8"));
        if (!"superalloy-save".equals(manifest.optString("format")) || manifest.optInt("formatVersion", -1) != 1) {
            throw new Exception("存档格式标识不正确");
        }
        String expected = manifest.optString("payloadSha256", "");
        if (!sha256(saveBytes).equalsIgnoreCase(expected)) throw new Exception("存档完整性校验失败");
        JSONObject result = new JSONObject();
        result.put("manifest", manifest);
        result.put("saveBase64", Base64.encodeToString(saveBytes, Base64.NO_WRAP));
        return result;
    }

    private static void writeArchive(File target, byte[] manifest, byte[] save) throws Exception {
        ZipOutputStream zip = new ZipOutputStream(new FileOutputStream(target));
        zip.putNextEntry(new ZipEntry("manifest.json"));
        zip.write(manifest);
        zip.closeEntry();
        zip.putNextEntry(new ZipEntry("save.bin"));
        zip.write(save);
        zip.closeEntry();
        zip.close();
    }

    private static byte[] readAll(InputStream input, int limit) throws Exception {
        if (input == null) throw new Exception("无法读取分享文件");
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buffer = new byte[8192];
        int total = 0;
        int read;
        while ((read = input.read(buffer)) >= 0) {
            total += read;
            if (total > limit) throw new Exception("存档文件过大");
            output.write(buffer, 0, read);
        }
        return output.toByteArray();
    }

    private static String sha256(byte[] data) throws Exception {
        byte[] hash = MessageDigest.getInstance("SHA-256").digest(data);
        StringBuilder text = new StringBuilder();
        for (byte value : hash) text.append(String.format("%02x", value & 255));
        return text.toString();
    }

    private static String cleanFileName(String value) {
        String name = value == null ? "superalloy-save.sasave" : value.replaceAll("[\\\\/:*?\"<>|\\p{Cntrl}]", "_").trim();
        if (name.length() == 0) name = "superalloy-save.sasave";
        if (!name.endsWith(".sasave")) name += ".sasave";
        return name;
    }

    private static String safeMessage(Throwable error) {
        String message = error.getMessage();
        return message == null || message.length() == 0 ? error.getClass().getSimpleName() : message;
    }

    private static String result(String status, String message, JSONObject extra) {
        try {
            JSONObject result = extra == null ? new JSONObject() : extra;
            result.put("status", status);
            result.put("message", message);
            return result.toString();
        } catch (Throwable ignored) {
            return "{\"status\":\"error\",\"message\":\"native result error\"}";
        }
    }

    private static FREObject stringObject(String value) {
        try { return FREObject.newObject(value); }
        catch (Throwable ignored) { return null; }
    }
}
