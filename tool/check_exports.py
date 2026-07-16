import struct

f = open(r'windows/Frameworks/pjsip.dll', 'rb').read()
e = struct.unpack_from('<I', f, 0x3C)[0]
coff = e + 4
numsec = struct.unpack_from('<H', f, coff + 2)[0]
sizeopt = struct.unpack_from('<H', f, coff + 16)[0]
opt = coff + 20
magic = struct.unpack_from('<H', f, opt)[0]
dd = opt + (112 if magic == 0x20b else 96)
exp_rva = struct.unpack_from('<I', f, dd)[0]
secs = []
sec = opt + sizeopt
for i in range(numsec):
    vsize, vaddr, rawsize, rawptr = struct.unpack_from('<IIII', f, sec + 8)
    secs.append((vaddr, vsize, rawptr, rawsize))
    sec += 40


def r(rva):
    best = None
    for va, vs, rp, rs in secs:
        if va <= rva and (best is None or va > best[0]):
            best = (va, rp)
    return best[1] + (rva - best[0]) if best else None


eo = r(exp_rva)
nc = struct.unpack_from('<I', f, eo + 24)[0]
nr = struct.unpack_from('<I', f, eo + 32)[0]
no = r(nr)
names = set()
for i in range(nc):
    o = r(struct.unpack_from('<I', f, no + 4 * i)[0])
    names.add(f[o:f.index(b'\x00', o)].decode())

called = """pjsua_acc_add pjsua_acc_config_default pjsua_acc_del2 pjsua_acc_del_param_default
pjsua_acc_get_info pjsua_acc_set_default pjsua_acc_set_registration pjsua_call_answer
pjsua_call_dial_dtmf pjsua_call_get_info pjsua_call_hangup pjsua_call_is_active
pjsua_call_make_call pjsua_call_reinvite pjsua_call_set_hold pjsua_call_setting_default
pjsua_codec_set_priority pjsua_conf_connect pjsua_conf_disconnect pjsua_conf_get_signal_level
pjsua_config_default pjsua_create pjsua_destroy pjsua_enum_aud_devs pjsua_enum_codecs
pjsua_get_snd_dev pjsua_handle_ip_change pjsua_init pjsua_ip_change_param_default
pjsua_logging_config_default pjsua_media_config_default pjsua_player_create pjsua_player_destroy
pjsua_player_get_conf_port pjsua_recorder_create pjsua_recorder_destroy pjsua_recorder_get_conf_port
pjsua_set_snd_dev pjsua_start pjsua_transport_config_default pjsua_transport_create""".split()

print("TOTAL EXPORTS:", len(names))
print("\nALL EXPORTS:")
for n in sorted(names):
    print("  ", n)
missing = [c for c in called if c not in names]
print("\nMISSING (called by Dart, NOT exported):", len(missing))
for m in missing:
    print("  MISSING", m)
