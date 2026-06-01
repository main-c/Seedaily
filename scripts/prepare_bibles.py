"""
Seedaily — Préparation des données bibliques
=============================================
Convertit les fichiers SQLite fournis (Bible SuperSearch) en fichiers JSON
par livre, puis crée un zip par version prêt à uploader sur Firebase Storage.

Sources SQLite attendues dans scripts/truth_*/FR-Français/ :
  - segond_1910.sqlite  → version id: lsg
  - martin.sqlite       → version id: martin
  - oster.sqlite        → version id: ostervald
  - epee.sqlite         → version id: epee

Usage :
    python3 scripts/prepare_bibles.py

Résultat :
    scripts/dist/lsg.zip
    scripts/dist/martin.zip
    scripts/dist/ostervald.zip
    scripts/dist/epee.zip

Upload Firebase Storage (Firebase CLI) :
    gsutil cp scripts/dist/lsg.zip       gs://<bucket>/bibles/lsg/lsg.zip
    gsutil cp scripts/dist/martin.zip    gs://<bucket>/bibles/martin/martin.zip
    gsutil cp scripts/dist/ostervald.zip gs://<bucket>/bibles/ostervald/ostervald.zip
    gsutil cp scripts/dist/epee.zip      gs://<bucket>/bibles/epee/epee.zip

Format JSON de sortie (un fichier par livre) :
    {
      "book": "Genèse",
      "chapters": [
        ["verset 1", "verset 2", ...],   ← chapitre 1 (index 0)
        ["verset 1", ...],               ← chapitre 2 (index 1)
        ...
      ]
    }
"""

import json
import re
import sqlite3
import zipfile
from pathlib import Path

# ── Chemins ────────────────────────────────────────────────────────────────────

SCRIPT_DIR  = Path(__file__).parent
SOURCE_DIR_FR = next(SCRIPT_DIR.glob("truth_*/FR-Français"), None)
SOURCE_DIR_EN = next(SCRIPT_DIR.glob("truth_*/EN-English"), None)
DIST_DIR    = SCRIPT_DIR / "dist"

# ── Versions à traiter ─────────────────────────────────────────────────────────

VERSIONS = [
    {"id": "lsg",       "file": "segond_1910.sqlite", "name": "Louis Segond 1910",        "lang": "fr"},
    {"id": "martin",    "file": "martin.sqlite",       "name": "Bible Martin 1744",         "lang": "fr"},
    {"id": "ostervald", "file": "oster.sqlite",        "name": "Bible Ostervald",           "lang": "fr"},
    {"id": "epee",      "file": "epee.sqlite",         "name": "Bible de l'Épée",           "lang": "fr"},
    {"id": "kjv",       "file": "kjv.sqlite",          "name": "King James Version",        "lang": "en"},
    {"id": "asv",       "file": "asv.sqlite",          "name": "American Standard Version", "lang": "en"},
]

# ── Noms français canoniques des 66 livres (numéro de livre 1-66) ──────────────

CANONICAL_BOOKS = {
     1: "Genèse",            2: "Exode",             3: "Lévitique",
     4: "Nombres",           5: "Deutéronome",        6: "Josué",
     7: "Juges",             8: "Ruth",               9: "1 Samuel",
    10: "2 Samuel",         11: "1 Rois",            12: "2 Rois",
    13: "1 Chroniques",     14: "2 Chroniques",      15: "Esdras",
    16: "Néhémie",          17: "Esther",            18: "Job",
    19: "Psaumes",          20: "Proverbes",         21: "Ecclésiaste",
    22: "Cantique des Cantiques", 23: "Ésaïe",       24: "Jérémie",
    25: "Lamentations",     26: "Ézéchiel",          27: "Daniel",
    28: "Osée",             29: "Joël",              30: "Amos",
    31: "Abdias",           32: "Jonas",             33: "Michée",
    34: "Nahum",            35: "Habacuc",           36: "Sophonie",
    37: "Aggée",            38: "Zacharie",          39: "Malachie",
    40: "Matthieu",         41: "Marc",              42: "Luc",
    43: "Jean",             44: "Actes",             45: "Romains",
    46: "1 Corinthiens",    47: "2 Corinthiens",     48: "Galates",
    49: "Éphésiens",        50: "Philippiens",       51: "Colossiens",
    52: "1 Thessaloniciens",53: "2 Thessaloniciens", 54: "1 Timothée",
    55: "2 Timothée",       56: "Tite",              57: "Philémon",
    58: "Hébreux",          59: "Jacques",           60: "1 Pierre",
    61: "2 Pierre",         62: "1 Jean",            63: "2 Jean",
    64: "3 Jean",           65: "Jude",              66: "Apocalypse",
}

# ── Utilitaires ────────────────────────────────────────────────────────────────

def clean_verse(text: str) -> str:
    """Nettoie le texte d'un verset (¶, espaces multiples, etc.)."""
    text = text.replace('¶', '').replace('\n', ' ')
    text = re.sub(r'  +', ' ', text)
    return text.strip()


def normalize_filename(book_name: str) -> str:
    """'1 Rois' → '1_rois.json', 'Ézéchiel' → 'ezechiel.json'"""
    name = book_name.lower()
    replacements = {
        'à':'a','á':'a','â':'a','ä':'a','è':'e','é':'e','ê':'e','ë':'e',
        'ì':'i','í':'i','î':'i','ï':'i','ò':'o','ó':'o','ô':'o','ö':'o',
        'ù':'u','ú':'u','û':'u','ü':'u','ý':'y','ÿ':'y','ç':'c',
    }
    for accent, plain in replacements.items():
        name = name.replace(accent, plain)
    name = re.sub(r'[^a-z0-9]', '_', name)
    name = re.sub(r'_+', '_', name).strip('_')
    return f"{name}.json"


def extract_version(db_path: Path) -> dict:
    """
    Extrait tous les versets d'une base SQLite.
    Retourne { book_num: { chapter: [verse_texts] } }
    """
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute("SELECT book, chapter, verse, text FROM verses ORDER BY book, chapter, verse")
    rows = cur.fetchall()
    conn.close()

    data = {}
    for book, chapter, verse, text in rows:
        data.setdefault(book, {}).setdefault(chapter, [])
        data[book][chapter].append(clean_verse(text))

    return data

# ── Traitement principal ───────────────────────────────────────────────────────

def main():
    if SOURCE_DIR_FR is None and SOURCE_DIR_EN is None:
        print("❌ Aucun dossier truth_* trouvé dans scripts/")
        return

    DIST_DIR.mkdir(exist_ok=True)
    print(f"Source FR : {SOURCE_DIR_FR}")
    print(f"Source EN : {SOURCE_DIR_EN}")
    print(f"Sortie    : {DIST_DIR}\n")

    for version in VERSIONS:
        source_dir = SOURCE_DIR_FR if version["lang"] == "fr" else SOURCE_DIR_EN
        if source_dir is None:
            print(f"⚠  Dossier source introuvable pour {version['name']}, ignoré.")
            continue
        db_path = source_dir / version["file"]
        if not db_path.exists():
            print(f"⚠  {version['name']} : fichier {version['file']} introuvable, ignoré.")
            continue

        print(f"── {version['name']} ({version['id']}) ──")

        # Extraire les données
        data = extract_version(db_path)
        print(f"   {len(data)} livres extraits")

        # Créer les fichiers JSON par livre dans un dossier temporaire
        tmp_dir = DIST_DIR / version["id"]
        tmp_dir.mkdir(exist_ok=True)

        for book_num, book_name in CANONICAL_BOOKS.items():
            if book_num not in data:
                print(f"   ⚠ Livre manquant : {book_name} (#{book_num})")
                continue

            chapters_dict = data[book_num]
            chapters_list = [
                chapters_dict[ch]
                for ch in sorted(chapters_dict.keys())
            ]

            book_json = {"book": book_name, "chapters": chapters_list}
            filename = normalize_filename(book_name)
            (tmp_dir / filename).write_text(
                json.dumps(book_json, ensure_ascii=False, separators=(',', ':')),
                encoding="utf-8",
            )

        # Zipper tous les JSON
        zip_path = DIST_DIR / f"{version['id']}.zip"
        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
            for json_file in sorted(tmp_dir.glob("*.json")):
                zf.write(json_file, json_file.name)

        size_kb = zip_path.stat().st_size // 1024
        print(f"   ✓ {zip_path.name} créé ({size_kb} KB)\n")

    # Instructions upload
    print("=" * 60)
    print("UPLOAD SUR FIREBASE STORAGE")
    print("=" * 60)
    print("Remplacer <bucket> par votre bucket Firebase (ex: seedaily-app.appspot.com)\n")
    for v in VERSIONS:
        vid = v["id"]
        zip_path = DIST_DIR / f"{vid}.zip"
        if zip_path.exists():
            print(f"  gsutil cp scripts/dist/{vid}.zip gs://<bucket>/bibles/{vid}/{vid}.zip")
    print()
    print("Ou via la console Firebase → Storage → Upload file.\n")
    print("Règles Firebase Storage (firestore.rules) :")
    print("  match /bibles/{allPaths=**} {")
    print("    allow read: if true;")
    print("    allow write: if false;")
    print("  }")


if __name__ == "__main__":
    main()
