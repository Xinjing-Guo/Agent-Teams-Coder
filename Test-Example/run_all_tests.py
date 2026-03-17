#!/usr/bin/env python3
"""
Comprehensive Test Runner for Agent Teams Project
Tester: Sentinel | Date: 2026-03-17

Runs all 5 test suites and generates individual logs + summary.
"""

import os
import json
import subprocess
import shutil
import sys
import time
from datetime import datetime, timezone

P = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TE = os.path.join(P, 'Test-Example')
SCRIPTS = os.path.join(P, 'scripts')
MEMORY = os.path.join(P, 'shared', 'memory')
NOTIFY = os.path.join(P, 'shared', 'notifications')
BACKUP = os.path.join(TE, '_backups')

# Global counters
class Counter:
    def __init__(self, name):
        self.name = name
        self.passed = 0
        self.failed = 0
        self.skipped = 0
        self.lines = []

    def p(self, msg):
        self.passed += 1
        self.lines.append(f'  [PASS] {msg}')

    def f(self, msg, detail=''):
        self.failed += 1
        self.lines.append(f'  [FAIL] {msg} -- {detail}')

    def s(self, msg):
        self.skipped += 1
        self.lines.append(f'  [SKIP] {msg}')

    def section(self, title):
        self.lines.append(f'\n{"="*50}\n{title}\n{"="*50}')

    def total(self):
        return self.passed + self.failed + self.skipped

    def rate(self):
        t = self.total()
        return (self.passed * 100 // t) if t > 0 else 0

    def summary_line(self):
        return f'{self.name}: Total={self.total()} Pass={self.passed} Fail={self.failed} Skip={self.skipped} Rate={self.rate()}%'

    def report(self):
        header = f'{"="*60}\n  {self.name}\n  Date: {datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")}\n{"="*60}\n'
        body = '\n'.join(self.lines)
        footer = f'\n\n{"="*60}\n  {self.summary_line()}\n{"="*60}\n'
        return header + body + footer


def run_script(script_path, *args):
    """Run a shell script and return (exit_code, stdout+stderr)."""
    try:
        result = subprocess.run(
            ['bash', script_path] + list(args),
            capture_output=True, text=True, timeout=30,
            cwd=os.path.dirname(script_path)
        )
        return result.returncode, result.stdout + result.stderr
    except subprocess.TimeoutExpired:
        return -1, 'TIMEOUT'
    except Exception as e:
        return -2, str(e)


def backup_shared_data():
    os.makedirs(BACKUP, exist_ok=True)
    for fn in ['shared-memory.json', 'approval-queue.json', 'status.json']:
        src = os.path.join(MEMORY, fn)
        if os.path.isfile(src):
            shutil.copy2(src, os.path.join(BACKUP, fn + '.bak'))
    if os.path.isdir(NOTIFY):
        dst = os.path.join(BACKUP, 'notifications_bak')
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(NOTIFY, dst)


def restore_shared_data():
    for fn in ['shared-memory.json', 'approval-queue.json', 'status.json']:
        bak = os.path.join(BACKUP, fn + '.bak')
        if os.path.isfile(bak):
            shutil.copy2(bak, os.path.join(MEMORY, fn))
    notify_bak = os.path.join(BACKUP, 'notifications_bak')
    if os.path.isdir(notify_bak):
        if os.path.isdir(NOTIFY):
            shutil.rmtree(NOTIFY)
        shutil.copytree(notify_bak, NOTIFY)
    if os.path.isdir(BACKUP):
        shutil.rmtree(BACKUP)


def reset_for_test():
    with open(os.path.join(MEMORY, 'shared-memory.json'), 'w') as f:
        json.dump({
            'meta': {'version': '1.0.0', 'description': 'TEST STATE',
                     'last_updated': '', 'updated_by': ''},
            'entries': {}
        }, f, indent=2)
    with open(os.path.join(MEMORY, 'approval-queue.json'), 'w') as f:
        json.dump({
            'meta': {'description': 'TEST STATE'},
            'requests': []
        }, f, indent=2)
    # Clean notification cache
    cache = os.path.join(NOTIFY, '.cache')
    if os.path.isdir(cache):
        shutil.rmtree(cache)


# ============================================================================
# TEST SUITE 1: Shell Scripts Functional Test
# ============================================================================
def test_scripts():
    c = Counter('Test 1: Shell Scripts Functional')
    backup_shared_data()
    reset_for_test()

    # Clean notifications for fresh test
    if os.path.isdir(NOTIFY):
        for fn in os.listdir(NOTIFY):
            fp = os.path.join(NOTIFY, fn)
            if os.path.isfile(fp) and fn.endswith('.json'):
                os.remove(fp)

    # --- 1. notify.sh ---
    c.section('notify.sh')

    # 1a: marshall -> euler
    code, out = run_script(os.path.join(SCRIPTS, 'notify.sh'), 'marshall', 'euler', 'TEST_subject_1', 'TEST_content')
    if code == 0 and 'euler' in out:
        c.p('notify.sh marshall->euler sent')
    else:
        c.f('notify.sh marshall->euler', f'code={code} out={out[:100]}')

    # Verify file
    ef = os.path.join(NOTIFY, 'euler.json')
    if os.path.isfile(ef):
        data = json.load(open(ef))
        if any(n['subject'] == 'TEST_subject_1' for n in data['notifications']):
            c.p('euler.json contains TEST_subject_1')
        else:
            c.f('euler.json content', 'TEST_subject_1 not found')
    else:
        c.f('euler.json', 'file not created')

    # 1b: forge -> all
    code, out = run_script(os.path.join(SCRIPTS, 'notify.sh'), 'forge', 'all', 'TEST_broadcast', 'bcast')
    broadcast_ok = True
    for agent in ['marshall', 'euler', 'sentinel', 'lens', 'atlas', 'chronicle']:
        af = os.path.join(NOTIFY, f'{agent}.json')
        if os.path.isfile(af):
            data = json.load(open(af))
            if not any(n['subject'] == 'TEST_broadcast' for n in data['notifications']):
                broadcast_ok = False
                c.f(f'broadcast to {agent}', 'not received')
        else:
            broadcast_ok = False
            c.f(f'broadcast to {agent}', f'{agent}.json not created')
    if broadcast_ok:
        c.p('forge->all: all 6 agents received broadcast')

    # Self-skip check
    ff = os.path.join(NOTIFY, 'forge.json')
    if os.path.isfile(ff):
        data = json.load(open(ff))
        if any(n['subject'] == 'TEST_broadcast' for n in data['notifications']):
            c.f('self-skip', 'forge received own broadcast')
        else:
            c.p('self-skip: forge did not get own broadcast')
    else:
        c.p('self-skip: forge.json not created (correct)')

    # Missing args
    code, out = run_script(os.path.join(SCRIPTS, 'notify.sh'))
    if code != 0:
        c.p('notify.sh missing args returns error')
    else:
        c.f('notify.sh missing args', 'did not error')

    # --- 2. check-notify.sh ---
    c.section('check-notify.sh')

    # Remove cache
    cache = os.path.join(NOTIFY, '.cache')
    if os.path.isdir(cache):
        shutil.rmtree(cache)

    code, out = run_script(os.path.join(SCRIPTS, 'check-notify.sh'), 'euler')
    if 'TEST_subject_1' in out or 'TEST_broadcast' in out or '未读' in out:
        c.p('check-notify euler: found unread')
    else:
        c.f('check-notify euler', f'out={out[:200]}')

    # Non-existent
    code, out = run_script(os.path.join(SCRIPTS, 'check-notify.sh'), 'nonexistent_xyz')
    if '无通知' in out:
        c.p('check-notify nonexistent: reports no notifications')
    else:
        c.f('check-notify nonexistent', f'out={out[:100]}')

    # Mtime cache recheck
    code, out = run_script(os.path.join(SCRIPTS, 'check-notify.sh'), 'euler')
    if '无新通知' in out or '无变化' in out:
        c.p('check-notify mtime cache works')
    else:
        c.f('check-notify mtime cache', f'out={out[:100]}')

    # --- 3. memory-request.sh ---
    c.section('memory-request.sh')

    code, out = run_script(os.path.join(SCRIPTS, 'memory-request.sh'), 'write', 'TEST_key_1', 'TEST_value_1', 'testing')
    if 'pending' in out or '已提交' in out:
        c.p('memory-request.sh submitted')
    else:
        c.f('memory-request.sh', f'out={out[:100]}')

    # Extract request ID
    req_id_1 = None
    for word in out.split():
        if word.startswith('req_'):
            req_id_1 = word
            break

    # Verify in queue
    q = json.load(open(os.path.join(MEMORY, 'approval-queue.json')))
    if any(r['key'] == 'TEST_key_1' and r['status'] == 'pending' for r in q['requests']):
        c.p('Request in queue with status=pending')
    else:
        c.f('Request in queue', 'not found as pending')

    # Invalid action
    code, out = run_script(os.path.join(SCRIPTS, 'memory-request.sh'), 'invalid_action', 'k', 'v', 'r')
    if code != 0:
        c.p('memory-request.sh rejects invalid action')
    else:
        c.f('memory-request.sh invalid action', 'did not error')

    # --- 4. memory-approve.sh ---
    c.section('memory-approve.sh')

    if req_id_1:
        code, out = run_script(os.path.join(SCRIPTS, 'memory-approve.sh'), req_id_1, 'test approval')
        if '已批准' in out or 'approved' in out:
            c.p(f'memory-approve.sh approved {req_id_1}')
        else:
            c.f('memory-approve.sh', f'out={out[:100]}')

        # Verify in shared-memory
        mem = json.load(open(os.path.join(MEMORY, 'shared-memory.json')))
        entry = mem.get('entries', {}).get('TEST_key_1')
        if entry and entry.get('content') == 'TEST_value_1':
            c.p('Approved entry written to shared-memory.json')
        else:
            c.f('Approved entry', 'not found in shared-memory.json')

        # Verify queue status
        q = json.load(open(os.path.join(MEMORY, 'approval-queue.json')))
        if any(r['id'] == req_id_1 and r['status'] == 'approved' for r in q['requests']):
            c.p('Queue status changed to approved')
        else:
            c.f('Queue status', f'{req_id_1} not approved')

        # Re-approve (should fail)
        code, out = run_script(os.path.join(SCRIPTS, 'memory-approve.sh'), req_id_1)
        if code != 0:
            c.p('Re-approval correctly rejected')
        else:
            c.f('Re-approval', 'should have been rejected')
    else:
        c.s('memory-approve tests (no request ID captured)')

    # Non-existent
    code, out = run_script(os.path.join(SCRIPTS, 'memory-approve.sh'), 'req_nonexistent_999')
    if code != 0:
        c.p('Approve non-existent request rejected')
    else:
        c.f('Approve non-existent', 'should have failed')

    # --- 5. memory-reject.sh ---
    c.section('memory-reject.sh')

    code, out = run_script(os.path.join(SCRIPTS, 'memory-request.sh'), 'write', 'TEST_key_reject', 'reject_val', 'will reject')
    req_id_2 = None
    for word in out.split():
        if word.startswith('req_'):
            req_id_2 = word
            break

    if req_id_2:
        code, out = run_script(os.path.join(SCRIPTS, 'memory-reject.sh'), req_id_2, 'test rejection')
        if '已拒绝' in out or 'rejected' in out:
            c.p(f'memory-reject.sh rejected {req_id_2}')
        else:
            c.f('memory-reject.sh', f'out={out[:100]}')

        q = json.load(open(os.path.join(MEMORY, 'approval-queue.json')))
        if any(r['id'] == req_id_2 and r['status'] == 'rejected' for r in q['requests']):
            c.p('Queue status changed to rejected')
        else:
            c.f('Queue rejection status', 'not found')

        mem = json.load(open(os.path.join(MEMORY, 'shared-memory.json')))
        if 'TEST_key_reject' not in mem.get('entries', {}):
            c.p('Rejected key NOT in shared-memory.json')
        else:
            c.f('Rejected key leak', 'key was written despite rejection')
    else:
        c.s('memory-reject tests (no request ID)')

    # --- 6. memory-write.sh ---
    c.section('memory-write.sh')

    code, out = run_script(os.path.join(SCRIPTS, 'memory-write.sh'), 'TEST_leader_key', 'TEST_leader_value')
    if '已更新' in out or 'updated' in out:
        c.p('memory-write.sh direct write success')
    else:
        c.f('memory-write.sh', f'out={out[:100]}')

    mem = json.load(open(os.path.join(MEMORY, 'shared-memory.json')))
    entry = mem.get('entries', {}).get('TEST_leader_key')
    if entry and entry['content'] == 'TEST_leader_value' and entry['author'] == 'leader':
        c.p('Direct write in shared-memory with author=leader')
    else:
        c.f('Direct write verify', f'entry={entry}')

    code, out = run_script(os.path.join(SCRIPTS, 'memory-write.sh'))
    if code != 0:
        c.p('memory-write.sh missing args errors')
    else:
        c.f('memory-write.sh missing args', 'no error')

    # --- 7. update-status.sh ---
    c.section('update-status.sh')

    code, out = run_script(os.path.join(SCRIPTS, 'update-status.sh'), 'marshall', 'working', 'TEST_task', '')
    if '已更新' in out or 'working' in out:
        c.p('update-status.sh marshall->working')
    else:
        c.f('update-status.sh', f'out={out[:100]}')

    st = json.load(open(os.path.join(MEMORY, 'status.json')))
    m = st['members']['marshall']
    if m['status'] == 'working' and 'TEST_task' in m['current_work']:
        c.p('status.json marshall updated correctly')
    else:
        c.f('status.json marshall', f'{m}')

    code, out = run_script(os.path.join(SCRIPTS, 'update-status.sh'), 'marshall', 'invalid_status')
    if code != 0:
        c.p('Invalid status rejected')
    else:
        c.f('Invalid status', 'not rejected')

    code, out = run_script(os.path.join(SCRIPTS, 'update-status.sh'), 'unknown_xyz', 'idle')
    if code != 0:
        c.p('Unknown agent rejected')
    else:
        c.f('Unknown agent', 'not rejected')

    # --- 8. update-phase.sh ---
    c.section('update-phase.sh')

    code, out = run_script(os.path.join(SCRIPTS, 'update-phase.sh'), '1', 'TEST_Phase')
    if '已更新' in out:
        c.p('update-phase.sh phase 1')
    else:
        c.f('update-phase.sh', f'out={out[:100]}')

    st = json.load(open(os.path.join(MEMORY, 'status.json')))
    ts = st['team_status']
    if ts['phase'] == '1' and 'TEST_Phase' in ts['current_task']:
        c.p('status.json phase updated correctly')
    else:
        c.f('status.json phase', f'{ts}')

    code, out = run_script(os.path.join(SCRIPTS, 'update-phase.sh'), '4', 'TEST_Code_Testing')
    if '已更新' in out and '代码测试' in out:
        c.p('update-phase.sh phase 4 with correct desc')
    else:
        c.f('update-phase.sh phase 4', f'out={out[:100]}')

    restore_shared_data()
    return c


# ============================================================================
# TEST SUITE 2: Agent Structure Validation
# ============================================================================
def test_agent_structure():
    c = Counter('Test 2: Agent Structure Validation')
    agents = ['leader', 'euler', 'forge', 'sentinel', 'lens', 'atlas', 'chronicle']
    expected_skills = {'leader': 4, 'euler': 6, 'forge': 6, 'sentinel': 5, 'lens': 4, 'atlas': 4, 'chronicle': 3}

    c.section('Agent directories')
    for a in agents:
        d = os.path.join(P, a)
        if os.path.isdir(d):
            c.p(f'{a}/ exists')
        else:
            c.f(f'{a}/', 'missing')

    c.section('PERSONA.md')
    for a in agents:
        fp = os.path.join(P, a, 'PERSONA.md')
        if os.path.isfile(fp) and os.path.getsize(fp) > 0:
            c.p(f'{a}/PERSONA.md ({os.path.getsize(fp)}B)')
        else:
            c.f(f'{a}/PERSONA.md', 'missing or empty')

    c.section('CLAUDE.md')
    for a in agents:
        fp = os.path.join(P, a, 'CLAUDE.md')
        if os.path.isfile(fp) and os.path.getsize(fp) > 0:
            c.p(f'{a}/CLAUDE.md ({os.path.getsize(fp)}B)')
        else:
            c.f(f'{a}/CLAUDE.md', 'missing or empty')

    c.section('skills/ directories')
    for a in agents:
        sd = os.path.join(P, a, 'skills')
        if os.path.isdir(sd):
            c.p(f'{a}/skills/ exists')
        else:
            c.f(f'{a}/skills/', 'missing')

    c.section('Skill count')
    for a in agents:
        sd = os.path.join(P, a, 'skills')
        if os.path.isdir(sd):
            files = [x for x in os.listdir(sd) if x.endswith('.md')]
            exp = expected_skills[a]
            if len(files) == exp:
                c.p(f'{a}: {len(files)} skills (expected {exp})')
            else:
                c.f(f'{a} skill count', f'expected {exp}, got {len(files)}: {files}')

    c.section('Skill files non-empty')
    for a in agents:
        sd = os.path.join(P, a, 'skills')
        if os.path.isdir(sd):
            for sf in sorted(os.listdir(sd)):
                if sf.endswith('.md'):
                    fp = os.path.join(sd, sf)
                    sz = os.path.getsize(fp)
                    if sz > 0:
                        c.p(f'{a}/skills/{sf} ({sz}B)')
                    else:
                        c.f(f'{a}/skills/{sf}', 'empty')

    return c


# ============================================================================
# TEST SUITE 3: Plugin Structure Validation
# ============================================================================
def test_plugin_structure():
    c = Counter('Test 3: Plugin Structure Validation')
    PL = os.path.join(P, 'plugin', 'agent-teams-coder')

    c.section('Plugin subdirectories')
    for d in ['agents', 'skills', 'hooks', 'commands', 'scripts']:
        if os.path.isdir(os.path.join(PL, d)):
            c.p(f'{d}/ exists')
        else:
            c.f(f'{d}/', 'missing')

    c.section('Agent definitions')
    for a in ['euler', 'forge', 'sentinel', 'lens', 'atlas', 'chronicle']:
        fp = os.path.join(PL, 'agents', f'{a}.md')
        if os.path.isfile(fp) and os.path.getsize(fp) > 0:
            c.p(f'{a}.md ({os.path.getsize(fp)}B)')
        else:
            c.f(f'{a}.md', 'missing or empty')

    # Check leader
    if os.path.isfile(os.path.join(PL, 'agents', 'marshall.md')) or os.path.isfile(os.path.join(PL, 'agents', 'leader.md')):
        c.p('Leader agent definition exists')
    else:
        c.f('Leader agent def', 'neither marshall.md nor leader.md found')

    c.section('plugin.json')
    pj = os.path.join(PL, '.claude-plugin', 'plugin.json')
    if os.path.isfile(pj):
        c.p('plugin.json exists')
        try:
            data = json.load(open(pj))
            c.p(f'plugin.json valid JSON (keys: {list(data.keys())})')
        except:
            c.f('plugin.json', 'invalid JSON')
    else:
        c.f('plugin.json', 'not found')

    c.section('Plugin skill files')
    sk_dir = os.path.join(PL, 'skills')
    cnt = 0
    for root, dirs, files in os.walk(sk_dir):
        for fn in files:
            if fn.endswith('.md'):
                fp = os.path.join(root, fn)
                sz = os.path.getsize(fp)
                rel = os.path.relpath(fp, sk_dir)
                cnt += 1
                if sz > 0:
                    c.p(f'skills/{rel} ({sz}B)')
                else:
                    c.f(f'skills/{rel}', 'empty')

    c.section('Scripts and commands')
    ls = os.path.join(PL, 'scripts', 'launch-team.sh')
    if os.path.isfile(ls):
        c.p('launch-team.sh exists')
    else:
        c.f('launch-team.sh', 'missing')

    cf = os.path.join(PL, 'commands', 'agent-team.md')
    if os.path.isfile(cf):
        c.p(f'agent-team.md ({os.path.getsize(cf)}B)')
    else:
        c.f('agent-team.md', 'missing')

    return c


# ============================================================================
# TEST SUITE 4: Shared Memory Integrity
# ============================================================================
def test_shared_memory():
    c = Counter('Test 4: Shared Memory Integrity')
    backup_shared_data()

    c.section('JSON file validity')
    for jf in ['shared-memory.json', 'approval-queue.json', 'status.json']:
        fp = os.path.join(MEMORY, jf)
        if os.path.isfile(fp):
            try:
                data = json.load(open(fp))
                c.p(f'{jf} is valid JSON')
            except:
                c.f(f'{jf}', 'invalid JSON')
        else:
            c.f(f'{jf}', 'file not found')

    c.section('shared-memory.json structure')
    try:
        data = json.load(open(os.path.join(MEMORY, 'shared-memory.json')))
        ok = True
        for key in ['meta', 'entries']:
            if key not in data:
                c.f(f'shared-memory.json', f'missing key: {key}')
                ok = False
        if 'meta' in data:
            for key in ['version', 'description', 'last_updated', 'updated_by']:
                if key not in data['meta']:
                    c.f(f'shared-memory.json meta', f'missing: {key}')
                    ok = False
        if ok:
            c.p('shared-memory.json structure correct')
    except Exception as e:
        c.f('shared-memory.json structure', str(e))

    c.section('approval-queue.json structure')
    try:
        data = json.load(open(os.path.join(MEMORY, 'approval-queue.json')))
        ok = True
        if 'requests' not in data:
            c.f('approval-queue.json', 'missing: requests')
            ok = False
        elif not isinstance(data['requests'], list):
            c.f('approval-queue.json', 'requests not a list')
            ok = False
        if ok:
            c.p('approval-queue.json structure correct')
    except Exception as e:
        c.f('approval-queue.json', str(e))

    c.section('status.json structure')
    try:
        data = json.load(open(os.path.join(MEMORY, 'status.json')))
        ok = True
        for key in ['meta', 'team_status', 'members']:
            if key not in data:
                c.f('status.json', f'missing: {key}')
                ok = False
        if 'members' in data:
            for m in ['marshall', 'euler', 'forge', 'sentinel', 'lens', 'atlas', 'chronicle']:
                if m not in data['members']:
                    c.f('status.json', f'missing member: {m}')
                    ok = False
                else:
                    for field in ['status', 'current_work', 'blockers', 'last_active']:
                        if field not in data['members'][m]:
                            c.f(f'status.json {m}', f'missing: {field}')
                            ok = False
        if ok:
            c.p('status.json has all 7 members with correct fields')
    except Exception as e:
        c.f('status.json', str(e))

    c.section('Orphaned notifications')
    valid = {'marshall', 'euler', 'forge', 'sentinel', 'lens', 'atlas', 'chronicle'}
    if os.path.isdir(NOTIFY):
        orphaned = 0
        for fn in os.listdir(NOTIFY):
            if fn.endswith('.json'):
                name = fn[:-5]
                if name in valid:
                    c.p(f'{fn} belongs to valid agent')
                else:
                    c.f(f'Orphaned: {fn}', 'not a known agent')
                    orphaned += 1
        if orphaned == 0:
            c.p('No orphaned notifications')
    else:
        c.p('No notifications directory (clean)')

    c.section('Concurrent access safety')
    reset_for_test()

    procs = []
    for i in range(1, 4):
        p_proc = subprocess.Popen(
            ['bash', os.path.join(SCRIPTS, 'memory-request.sh'), 'write',
             f'TEST_concurrent_{i}', f'value_{i}', f'concurrent test {i}'],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        procs.append(p_proc)

    for p_proc in procs:
        p_proc.wait()

    q = json.load(open(os.path.join(MEMORY, 'approval-queue.json')))
    test_reqs = [r for r in q['requests'] if r['key'].startswith('TEST_concurrent_')]
    if len(test_reqs) == 3:
        c.p(f'All 3 concurrent requests recorded')
    else:
        c.f('Concurrent access', f'expected 3 requests, got {len(test_reqs)} (race condition)')

    try:
        json.load(open(os.path.join(MEMORY, 'approval-queue.json')))
        c.p('Queue still valid JSON after concurrent writes')
    except:
        c.f('JSON integrity', 'corrupted after concurrent writes')

    restore_shared_data()
    return c


# ============================================================================
# TEST SUITE 5: Start Scripts Validation
# ============================================================================
def test_start_scripts():
    c = Counter('Test 5: Start Scripts Validation')
    agents = ['leader', 'euler', 'forge', 'sentinel', 'lens', 'atlas', 'chronicle']

    c.section('Start scripts existence')
    for a in agents:
        s = os.path.join(P, f'start-{a}.sh')
        if os.path.isfile(s):
            c.p(f'start-{a}.sh exists')
        else:
            c.f(f'start-{a}.sh', 'missing')

    c.section('Shebang and content')
    for a in agents:
        s = os.path.join(P, f'start-{a}.sh')
        if os.path.isfile(s):
            content = open(s).read()
            has_shebang = content.startswith('#!/bin/bash')
            has_agent = a in content
            has_claude = 'claude' in content
            has_model = 'opus' in content or 'MODEL' in content

            if has_shebang:
                c.p(f'start-{a}.sh has shebang')
            else:
                c.f(f'start-{a}.sh', 'no shebang')

            if has_agent:
                c.p(f'start-{a}.sh references {a}')
            else:
                c.f(f'start-{a}.sh', f'no reference to {a}')

            if has_claude:
                c.p(f'start-{a}.sh invokes claude')
            else:
                c.f(f'start-{a}.sh', 'no claude invocation')

            if has_model:
                c.p(f'start-{a}.sh supports model selection')
            else:
                c.f(f'start-{a}.sh', 'no model support')

    c.section('panel.sh')
    panel = os.path.join(P, 'panel.sh')
    if os.path.isfile(panel):
        c.p('panel.sh exists')
        content = open(panel).read()
        if content.startswith('#!/bin/bash'):
            c.p('panel.sh has shebang')
        else:
            c.f('panel.sh', 'no shebang')
        if 'tmux' in content:
            c.p('panel.sh references tmux')
        else:
            c.f('panel.sh', 'no tmux reference')
        refs = sum(1 for a in agents if a in content)
        if refs >= 5:
            c.p(f'panel.sh references {refs}/7 agents')
        else:
            c.f('panel.sh agent coverage', f'only {refs}/7')
    else:
        c.f('panel.sh', 'missing')

    return c


# ============================================================================
# MAIN RUNNER
# ============================================================================
if __name__ == '__main__':
    print('='*64)
    print('  Agent Teams Comprehensive Test Suite')
    print(f'  Date: {datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")}')
    print(f'  Tester: Sentinel')
    print('='*64)
    print()

    suites = [
        ('test-scripts', test_scripts),
        ('test-agent-structure', test_agent_structure),
        ('test-plugin-structure', test_plugin_structure),
        ('test-shared-memory', test_shared_memory),
        ('test-start-scripts', test_start_scripts),
    ]

    all_results = []
    for name, func in suites:
        print(f'\n>>> Running: {name} ...')
        try:
            counter = func()
        except Exception as e:
            counter = Counter(name)
            counter.f('Suite crashed', str(e))

        report = counter.report()
        print(report)

        # Save individual log
        log_path = os.path.join(TE, f'{name}.log')
        with open(log_path, 'w') as f:
            f.write(report)
        print(f'  Log saved: {log_path}')

        all_results.append(counter)

    # Generate summary
    total_p = sum(c.passed for c in all_results)
    total_f = sum(c.failed for c in all_results)
    total_s = sum(c.skipped for c in all_results)
    total_all = total_p + total_f + total_s

    summary = f"""# Test Report -- Agent Teams Project

Date: {datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")} | Tester: Sentinel

## Summary

- Total cases: {total_all}
- Passed: {total_p} ({total_p*100//total_all if total_all else 0}%)
- Failed: {total_f} ({total_f*100//total_all if total_all else 0}%)
- Skipped: {total_s} ({total_s*100//total_all if total_all else 0}%)

## Test Environment

- Language: Python {sys.version.split()[0]} / Bash
- OS: macOS (Darwin)
- Project: Agent Teams v1.0.1

## Suite Results

| # | Suite | Total | Pass | Fail | Skip | Rate |
|---|-------|-------|------|------|------|------|
"""
    for i, c in enumerate(all_results, 1):
        summary += f'| {i} | {c.name} | {c.total()} | {c.passed} | {c.failed} | {c.skipped} | {c.rate()}% |\n'

    # Collect failed cases
    failed_cases = []
    for c in all_results:
        for line in c.lines:
            if '[FAIL]' in line:
                failed_cases.append((c.name, line.strip()))

    if failed_cases:
        summary += '\n## Failed Cases\n\n| # | Suite | Case | Detail |\n|---|-------|------|--------|\n'
        for i, (suite, line) in enumerate(failed_cases, 1):
            parts = line.replace('[FAIL] ', '').split(' -- ', 1)
            case = parts[0]
            detail = parts[1] if len(parts) > 1 else ''
            summary += f'| {i} | {suite} | {case} | {detail} |\n'

        summary += '\n## Bug List\n\n'
        for i, (suite, line) in enumerate(failed_cases, 1):
            parts = line.replace('[FAIL] ', '').split(' -- ', 1)
            summary += f"""### BUG-{i:03d}: {parts[0]}

- Severity: Minor
- Suite: {suite}
- Detail: {parts[1] if len(parts) > 1 else 'N/A'}
- Steps to reproduce: Run the corresponding test suite
- Suggested fix: Investigate the specific check that failed

"""
    else:
        summary += '\n## Failed Cases\n\nNone -- all tests passed.\n'

    verdict = 'PASS' if total_f == 0 else 'FAIL'
    summary += f"""## Conclusion

**{verdict}** -- {total_p}/{total_all} tests passed ({total_p*100//total_all if total_all else 0}%).
"""
    if total_f > 0:
        summary += f'{total_f} test(s) failed. See Bug List above for details.\n'
    else:
        summary += 'All test suites completed successfully. No bugs found.\n'

    summary_path = os.path.join(TE, 'test-summary.md')
    with open(summary_path, 'w') as f:
        f.write(summary)

    print('\n' + '='*64)
    print('  FINAL SUMMARY')
    print('='*64)
    print(f'  Total: {total_all} | Pass: {total_p} | Fail: {total_f} | Skip: {total_s}')
    print(f'  Rate: {total_p*100//total_all if total_all else 0}%')
    print(f'  Verdict: {verdict}')
    print(f'  Summary: {summary_path}')
    print('='*64)
