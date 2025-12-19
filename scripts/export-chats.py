#!/usr/bin/env python3
"""
CLAUDE CODE - Export Chat in formato leggibile
Autore: Eliseo Bosco
Progetto: PRG0020_CLAUDEAI_PROFILO_EB

Esporta le sessioni di chat di Claude Code in formato Markdown leggibile.
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
import argparse

# Configurazione
CLAUDE_HOME = Path.home() / ".claude"
PROJECTS_DIR = CLAUDE_HOME / "projects"
HISTORY_FILE = CLAUDE_HOME / "history.jsonl"


def parse_jsonl(file_path: Path) -> list:
    """Legge un file JSONL e restituisce una lista di oggetti."""
    entries = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        entries.append(json.loads(line))
                    except json.JSONDecodeError:
                        continue
    except Exception as e:
        print(f"Errore lettura {file_path}: {e}")
    return entries


def format_timestamp(ts: int) -> str:
    """Converte timestamp milliseconds in stringa leggibile."""
    try:
        dt = datetime.fromtimestamp(ts / 1000)
        return dt.strftime("%Y-%m-%d %H:%M:%S")
    except:
        return "N/A"


def extract_text_content(content) -> str:
    """Estrae il testo da vari formati di contenuto."""
    if isinstance(content, str):
        return content
    elif isinstance(content, list):
        texts = []
        for item in content:
            if isinstance(item, dict):
                if item.get('type') == 'text':
                    texts.append(item.get('text', ''))
                elif item.get('type') == 'tool_use':
                    tool_name = item.get('name', 'unknown')
                    texts.append(f"[Tool: {tool_name}]")
                elif item.get('type') == 'tool_result':
                    texts.append("[Tool Result]")
            elif isinstance(item, str):
                texts.append(item)
        return '\n'.join(texts)
    elif isinstance(content, dict):
        if content.get('type') == 'text':
            return content.get('text', '')
    return str(content)


def export_session_to_markdown(session_file: Path, output_dir: Path) -> str:
    """Esporta una singola sessione in formato Markdown."""
    entries = parse_jsonl(session_file)
    if not entries:
        return None

    session_id = session_file.stem
    output_file = output_dir / f"{session_id}.md"

    # Trova informazioni sulla sessione
    first_timestamp = None
    last_timestamp = None
    project_path = None

    messages = []

    for entry in entries:
        # Estrai timestamp
        ts = entry.get('timestamp')
        if ts:
            if first_timestamp is None or ts < first_timestamp:
                first_timestamp = ts
            if last_timestamp is None or ts > last_timestamp:
                last_timestamp = ts

        # Estrai progetto
        if not project_path:
            project_path = entry.get('cwd') or entry.get('project')

        # Estrai messaggi
        msg_type = entry.get('type')

        if msg_type == 'user':
            content = entry.get('message', {})
            if isinstance(content, dict):
                text = extract_text_content(content.get('content', ''))
            else:
                text = str(content)
            if text:
                messages.append(('user', text, ts))

        elif msg_type == 'assistant':
            content = entry.get('message', {})
            if isinstance(content, dict):
                text = extract_text_content(content.get('content', ''))
            else:
                text = str(content)
            if text:
                messages.append(('assistant', text, ts))

        # Gestione formato alternativo
        elif 'message' in entry and 'role' in entry.get('message', {}):
            msg = entry['message']
            role = msg.get('role', 'unknown')
            text = extract_text_content(msg.get('content', ''))
            if text and role in ['user', 'assistant']:
                messages.append((role, text, ts))

    if not messages:
        return None

    # Genera Markdown
    md_content = []
    md_content.append(f"# Chat Session: {session_id}\n")
    md_content.append(f"**Data inizio**: {format_timestamp(first_timestamp)}\n")
    md_content.append(f"**Data fine**: {format_timestamp(last_timestamp)}\n")
    if project_path:
        md_content.append(f"**Progetto**: `{project_path}`\n")
    md_content.append("\n---\n")

    for role, text, ts in messages:
        timestamp_str = format_timestamp(ts) if ts else ""

        if role == 'user':
            md_content.append(f"\n## User ({timestamp_str})\n")
        else:
            md_content.append(f"\n## Assistant ({timestamp_str})\n")

        # Limita lunghezza per leggibilita'
        if len(text) > 10000:
            text = text[:10000] + "\n\n... [troncato] ..."

        md_content.append(text)
        md_content.append("\n")

    # Scrivi file
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(md_content))

    return str(output_file)


def export_history_index(output_dir: Path) -> str:
    """Esporta l'indice della cronologia."""
    if not HISTORY_FILE.exists():
        return None

    entries = parse_jsonl(HISTORY_FILE)
    if not entries:
        return None

    output_file = output_dir / "history_index.md"

    md_content = []
    md_content.append("# Claude Code - Cronologia Comandi\n")
    md_content.append(f"Esportato il: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    md_content.append("\n---\n")

    # Raggruppa per sessione
    sessions = {}
    for entry in entries:
        session_id = entry.get('sessionId', 'unknown')
        if session_id not in sessions:
            sessions[session_id] = []
        sessions[session_id].append(entry)

    for session_id, session_entries in sessions.items():
        md_content.append(f"\n## Sessione: {session_id[:8]}...\n")

        for entry in session_entries[:50]:  # Limita a 50 per sessione
            ts = format_timestamp(entry.get('timestamp', 0))
            display = entry.get('display', '')
            if display:
                # Tronca messaggi lunghi
                if len(display) > 200:
                    display = display[:200] + "..."
                md_content.append(f"- `{ts}` - {display}\n")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(md_content))

    return str(output_file)


def list_sessions() -> list:
    """Lista tutte le sessioni disponibili."""
    sessions = []

    if not PROJECTS_DIR.exists():
        return sessions

    for project_dir in PROJECTS_DIR.iterdir():
        if project_dir.is_dir():
            for session_file in project_dir.glob("*.jsonl"):
                if not session_file.name.startswith("agent-"):
                    sessions.append({
                        'project': project_dir.name,
                        'session_id': session_file.stem,
                        'path': session_file,
                        'size': session_file.stat().st_size,
                        'modified': datetime.fromtimestamp(session_file.stat().st_mtime)
                    })

    return sorted(sessions, key=lambda x: x['modified'], reverse=True)


def main():
    parser = argparse.ArgumentParser(
        description='Esporta chat Claude Code in formato Markdown'
    )
    parser.add_argument(
        '-o', '--output',
        default='./exports',
        help='Directory di output (default: ./exports)'
    )
    parser.add_argument(
        '-l', '--list',
        action='store_true',
        help='Lista sessioni disponibili'
    )
    parser.add_argument(
        '-s', '--session',
        help='Esporta solo una sessione specifica (ID)'
    )
    parser.add_argument(
        '-a', '--all',
        action='store_true',
        help='Esporta tutte le sessioni'
    )
    parser.add_argument(
        '--history',
        action='store_true',
        help='Esporta anche indice cronologia'
    )

    args = parser.parse_args()

    # Lista sessioni
    if args.list:
        sessions = list_sessions()
        print(f"\nSessioni disponibili: {len(sessions)}\n")
        print(f"{'Session ID':<40} {'Progetto':<30} {'Dimensione':<12} {'Modificato'}")
        print("-" * 100)
        for s in sessions[:20]:
            size_kb = s['size'] / 1024
            print(f"{s['session_id']:<40} {s['project'][:28]:<30} {size_kb:>8.1f} KB   {s['modified'].strftime('%Y-%m-%d %H:%M')}")
        if len(sessions) > 20:
            print(f"\n... e altre {len(sessions) - 20} sessioni")
        return

    # Crea directory output
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    exported = []

    # Esporta sessione specifica
    if args.session:
        sessions = list_sessions()
        for s in sessions:
            if args.session in s['session_id']:
                result = export_session_to_markdown(s['path'], output_dir)
                if result:
                    exported.append(result)
                    print(f"Esportato: {result}")
                break
        else:
            print(f"Sessione non trovata: {args.session}")

    # Esporta tutte le sessioni
    elif args.all:
        sessions = list_sessions()
        print(f"Esportando {len(sessions)} sessioni...")
        for s in sessions:
            result = export_session_to_markdown(s['path'], output_dir)
            if result:
                exported.append(result)
                print(f"  Esportato: {s['session_id'][:20]}...")

    # Esporta cronologia
    if args.history or (not args.session and not args.all):
        result = export_history_index(output_dir)
        if result:
            exported.append(result)
            print(f"Esportato indice cronologia: {result}")

    print(f"\nTotale file esportati: {len(exported)}")
    print(f"Directory output: {output_dir.absolute()}")


if __name__ == '__main__':
    main()
