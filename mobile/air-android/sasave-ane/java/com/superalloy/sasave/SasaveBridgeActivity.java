package com.superalloy.sasave;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Base64;
import android.widget.Toast;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.security.MessageDigest;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import org.json.JSONObject;

public final class SasaveBridgeActivity extends Activity {
    private static final int CREATE_DOCUMENT = 4101;
    private static final int OPEN_DOCUMENT = 4102;
    private static final int MAX_ARCHIVE_BYTES = 8 * 1024 * 1024;
    private static final int MAX_ENTRY_BYTES = 4 * 1024 * 1024;
    private File pendingArchive;

    protected void onCreate(Bundle state) {
        super.onCreate(state);
        try {
            Intent intent = getIntent();
            Uri data = intent.getData();
            if (data != null && "sasavebridge".equals(data.getScheme())) {
                if ("import".equals(data.getHost())) openImportPicker();
                else exportSave(data);
            } else {
                importSave(intent);
            }
        } catch (Throwable error) {
            Toast.makeText(this, safeMessage(error), Toast.LENGTH_LONG).show();
            finish();
        }
    }

    private void openImportPicker() {
        Intent open = new Intent("android.intent.action.OPEN_DOCUMENT");
        open.addCategory(Intent.CATEGORY_OPENABLE);
        open.setType("*/*");
        open.putExtra("android.intent.extra.MIME_TYPES", new String[] {
            "application/x-sasave", "application/zip", "application/octet-stream"
        });
        startActivityForResult(open, OPEN_DOCUMENT);
    }

    private void exportSave(Uri command) throws Exception {
        byte[] saveBytes = readFile(new File(command.getQueryParameter("save")), MAX_ENTRY_BYTES);
        byte[] manifestBytes = readFile(new File(command.getQueryParameter("manifest")), MAX_ENTRY_BYTES);
        JSONObject manifest = new JSONObject(new String(manifestBytes, "UTF-8"));
        manifest.put("payloadSha256", sha256(saveBytes));
        String fileName = cleanFileName(command.getQueryParameter("name"));
        File directory = new File(getCacheDir(), "sasave_exports");
        if (!directory.exists() && !directory.mkdirs()) throw new Exception("无法建立导出缓存目录");
        pendingArchive = new File(directory, fileName);
        writeArchive(pendingArchive, manifest.toString().getBytes("UTF-8"), saveBytes);
        if ("share".equals(command.getHost())) {
            Uri shareUri = Uri.parse("content://" + getPackageName() + ".sasave/" + Uri.encode(fileName));
            Intent send = new Intent(Intent.ACTION_SEND);
            send.setType("application/x-sasave");
            send.putExtra(Intent.EXTRA_STREAM, shareUri);
            send.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            startActivity(Intent.createChooser(send, "分享超合金战记存档"));
            finish();
            return;
        }
        Intent create = new Intent("android.intent.action.CREATE_DOCUMENT");
        create.addCategory(Intent.CATEGORY_OPENABLE);
        create.setType("application/x-sasave");
        create.putExtra(Intent.EXTRA_TITLE, fileName);
        startActivityForResult(create, CREATE_DOCUMENT);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == OPEN_DOCUMENT) {
            if (resultCode == RESULT_OK && data != null && data.getData() != null) {
                try {
                    Intent selected = new Intent(Intent.ACTION_VIEW, data.getData());
                    importSave(selected);
                } catch (Throwable error) {
                    Toast.makeText(this, "导入失败：" + safeMessage(error), Toast.LENGTH_LONG).show();
                    finish();
                }
            } else {
                finish();
            }
            return;
        }
        if (requestCode != CREATE_DOCUMENT) return;
        if (resultCode == RESULT_OK && data != null && data.getData() != null) {
            try {
                OutputStream output = getContentResolver().openOutputStream(data.getData());
                InputStream input = new FileInputStream(pendingArchive);
                copy(input, output, MAX_ARCHIVE_BYTES);
                input.close();
                output.close();
                Toast.makeText(this, "存档已导出，可在所选目录中查看", Toast.LENGTH_LONG).show();
            } catch (Throwable error) {
                Toast.makeText(this, "导出失败：" + safeMessage(error), Toast.LENGTH_LONG).show();
            }
        }
        finish();
    }

    private void importSave(Intent intent) throws Exception {
        Uri uri = incomingUri(intent);
        if (uri == null) throw new Exception("没有收到可导入的存档文件");
        InputStream incoming = getContentResolver().openInputStream(uri);
        JSONObject parsed = parseArchive(readAll(incoming, MAX_ARCHIVE_BYTES));
        incoming.close();
        File saveFile = new File(getFilesDir(), "incoming-superalloy-save.bin");
        FileOutputStream saveOutput = new FileOutputStream(saveFile);
        saveOutput.write(Base64.decode(parsed.remove("saveBase64").toString(), Base64.DEFAULT));
        saveOutput.close();
        parsed.put("status", "ok");
        parsed.put("cachePath", saveFile.getAbsolutePath());
        FileOutputStream resultOutput = new FileOutputStream(new File(getFilesDir(), "incoming-superalloy-save.json"));
        resultOutput.write(parsed.toString().getBytes("UTF-8"));
        resultOutput.close();
        Toast.makeText(this, "已接收存档，请在游戏中点击导入存档", Toast.LENGTH_LONG).show();
        Intent launch = getPackageManager().getLaunchIntentForPackage(getPackageName());
        if (launch != null) {
            launch.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            startActivity(launch);
        }
        finish();
    }

    private static Uri incomingUri(Intent intent) {
        if (Intent.ACTION_SEND.equals(intent.getAction())) {
            Object stream = intent.getParcelableExtra(Intent.EXTRA_STREAM);
            return stream instanceof Uri ? (Uri) stream : null;
        }
        return Intent.ACTION_VIEW.equals(intent.getAction()) ? intent.getData() : null;
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
            if (entry.isDirectory() || name.indexOf('/') >= 0 || name.indexOf('\\') >= 0 || name.indexOf("..") >= 0) throw new Exception("存档压缩包包含非法路径");
            byte[] data = readAll(zip, MAX_ENTRY_BYTES);
            if ("manifest.json".equals(name)) manifestBytes = data;
            else if ("save.bin".equals(name)) saveBytes = data;
            else throw new Exception("存档压缩包包含非本游戏文件");
            zip.closeEntry();
        }
        zip.close();
        if (entries != 2 || manifestBytes == null || saveBytes == null) throw new Exception("不是有效的本游戏存档包");
        JSONObject manifest = new JSONObject(new String(manifestBytes, "UTF-8"));
        if (!"superalloy-save".equals(manifest.optString("format")) || manifest.optInt("formatVersion", -1) != 1) throw new Exception("存档格式标识不正确");
        if (!sha256(saveBytes).equalsIgnoreCase(manifest.optString("payloadSha256", ""))) throw new Exception("存档完整性校验失败");
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

    private static void copy(InputStream input, OutputStream output, int limit) throws Exception {
        byte[] buffer = new byte[8192];
        int total = 0;
        int read;
        while ((read = input.read(buffer)) >= 0) {
            total += read;
            if (total > limit) throw new Exception("存档文件过大");
            output.write(buffer, 0, read);
        }
    }

    private static byte[] readFile(File file, int limit) throws Exception {
        InputStream input = new FileInputStream(file);
        byte[] data = readAll(input, limit);
        input.close();
        return data;
    }

    private static byte[] readAll(InputStream input, int limit) throws Exception {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        copy(input, output, limit);
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
}
