# -*- coding: utf-8 -*-
# enable_scout_telemetry.py — 给 SWF 注入 EnableTelemetry(tag 93) 标记，供 Adobe Scout 采样
# 算法与 Adobe telemetry-tools add-opt-in.py(BSD) 等价：tag 93 插在 FileAttributes(69) 之后(跳过紧随的 Metadata 77)，
# payload = 2 字节保留字段；CWS 解压→插→zlib 重压→回写 FileLength；已有 tag 93 或签名 SWF(92) 则拒绝。
# 用法: python enable_scout_telemetry.py <swf路径>   （原地修改，自动留 .bak 备份）
import struct, sys, zlib, shutil, hashlib, os

def read_tags(body):
    nbits = body[0] >> 3
    pos = (5 + 4 * nbits + 7) // 8 + 4  # 跳过 RECT + 帧率(2) + 帧数(2)
    out = []
    while pos + 2 <= len(body):
        v = struct.unpack_from('<H', body, pos)[0]
        code = v >> 6
        if code == 0:
            break
        ln = v & 0x3f
        hdr = 2
        if ln == 0x3f:
            ln = struct.unpack_from('<I', body, pos + 2)[0]
            hdr = 6
        out.append((code, pos, hdr, ln))
        pos += hdr + ln
    return out, pos

def main(path):
    raw = open(path, 'rb').read()
    sig = raw[:3]
    assert sig in (b'CWS', b'FWS'), '不是 SWF: %s' % sig
    if sig == b'FWS':
        raise SystemExit('FWS 未压缩 SWF 请先确认来源；本脚本按 CWS 流程同样适用，但请自查')
    body = bytearray(zlib.decompress(raw[8:]))
    tags, end = read_tags(body)
    codes = [c for c, _, _, _ in tags]
    assert 93 not in codes, '已存在 EnableTelemetry，无需重复注入'
    assert 92 not in codes, '签名 SWF(92)，拒绝处理'
    assert 69 in codes, '缺少 FileAttributes(69)'
    insert_at = None
    for i, (code, pos, hdr, ln) in enumerate(tags):
        if code == 69:
            insert_at = pos + hdr + ln
            nxt = tags[i + 1] if i + 1 < len(tags) else None
            if nxt and nxt[0] == 77:
                insert_at = nxt[1] + nxt[2] + nxt[3]
            break
    assert insert_at is not None
    payload = struct.pack('<H', 0)
    tel = struct.pack('<H', 93 << 6 | len(payload)) + payload
    new_body = bytes(body[:insert_at]) + tel + bytes(body[insert_at:])
    uncompressed_len = 8 + len(new_body)
    head = bytearray(raw[:8])
    struct.pack_into('<I', head, 4, uncompressed_len)
    out = bytes(head) + zlib.compress(bytes(new_body))
    shutil.copyfile(path, path + '.bak')
    open(path, 'wb').write(out)
    print('[OK] EnableTelemetry 注入完成: %s' % path)
    print('     原始 %d 字节 -> %d 字节；备份: %s.bak' % (len(raw), len(out), path))
    print('     SHA256:', hashlib.sha256(out).hexdigest().upper()[:16])

if __name__ == '__main__':
    main(sys.argv[1])
