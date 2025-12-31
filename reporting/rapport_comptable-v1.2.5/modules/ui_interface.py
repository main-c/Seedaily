#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module 4: Interface Utilisateur pour la saisie des commentaires

Ce module fournit une interface graphique complète pour saisir les commentaires
qui seront intégrés dans la présentation PowerPoint.

Fonctionnalités:
- Interface de configuration initiale (fichier source, dossier sortie)
- Génération automatique des documents Excel/PowerPoint
- Interface avec onglets pour enrichir les commentaires
- Saisie avec formatage riche (gras, italique, puces)
- Sauvegarde/chargement des commentaires en format texte
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog, font as tkfont
import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict
import ctypes

# Import pour charger les clients disponibles
import sys
sys.path.insert(0, str(Path(__file__).parent))
from data_processor import get_available_clients

logger = logging.getLogger(__name__)


class ConfigurationInterface:
    """Interface de configuration initiale pour sélectionner les fichiers et options"""

    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Configuration - Générateur de Rapports Comptables")

        # Calculer une taille dynamique basée sur la résolution de l'écran
        # Utiliser la zone de travail (workarea) quand elle est disponible
        def _get_workarea_size(root: tk.Tk):
            # S'assurer que Tk a initialisé ses informations
            root.update_idletasks()

            # Sur Windows, récupérer la workarea (exclut la barre des tâches)
            if sys.platform == "win32":
                try:
                    class RECT(ctypes.Structure):
                        _fields_ = [("left", ctypes.c_long), ("top", ctypes.c_long), ("right", ctypes.c_long), ("bottom", ctypes.c_long)]

                    SPI_GETWORKAREA = 0x0030
                    rect = RECT()
                    res = ctypes.windll.user32.SystemParametersInfoW(SPI_GETWORKAREA, 0, ctypes.byref(rect), 0)
                    if res:
                        width = rect.right - rect.left
                        height = rect.bottom - rect.top
                        return width, height
                except Exception:
                    # Si l'appel native échoue, on retombe sur winfo
                    pass

            # Fallback pour Linux/macOS et si l'appel Windows échoue
            return root.winfo_screenwidth(), root.winfo_screenheight()

        screen_width, screen_height = _get_workarea_size(self.root)

        # Utiliser 50% de la largeur et 70% de la hauteur de l'écran
        window_width = min(int(screen_width * 0.5), 700)  # Maximum 700px
        window_height = min(int(screen_height * 0.7), 800)  # Maximum 800px

        # Centrer la fenêtre
        x = (screen_width // 2) - (window_width // 2)
        y = (screen_height // 2) - (window_height // 2)

        self.root.geometry(f"{window_width}x{window_height}+{x}+{y}")

        self.config_data = None

        # Variables
        self.fichier_sage_var = tk.StringVar()
        self.dossier_sortie_var = tk.StringVar(value=str(Path.home() / "Documents"))
        self.generer_excel_var = tk.BooleanVar(value=True)
        self.generer_ppt_var = tk.BooleanVar(value=True)
        self.periode_var = tk.StringVar()
        self.cabinet_var = tk.StringVar(value="2BN CONSULTING")
        self.client_var = tk.StringVar(value="BAMBOO IMMO")

        # Charger les clients disponibles depuis les mappings
        self.available_clients = self._load_available_clients()

        self.setup_ui()

    def setup_ui(self):
        """Configure l'interface de configuration"""
        # Frame principal (scrollable) — utilise un Canvas + Scrollbar
        container = ttk.Frame(self.root)
        container.pack(fill=tk.BOTH, expand=True)

        # Canvas pour le contenu scrollable et scrollbar verticale
        canvas = tk.Canvas(container, borderwidth=0, highlightthickness=0)
        vscroll = ttk.Scrollbar(container, orient="vertical", command=canvas.yview)
        canvas.configure(yscrollcommand=vscroll.set)

        vscroll.pack(side=tk.RIGHT, fill=tk.Y)
        canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        # Frame intérieur qui contiendra le layout principal
        main_frame = ttk.Frame(canvas, padding="20")
        canvas.create_window((0, 0), window=main_frame, anchor="nw")

        # Met à jour la region scrollable quand le contenu change
        def _on_frame_configure(event, canvas=canvas):
            canvas.configure(scrollregion=canvas.bbox("all"))

        main_frame.bind("<Configure>", _on_frame_configure)

        # Support de la molette souris (Windows/Mac/Linux)
        def _on_mousewheel(event, canvas=canvas):
            # Pour Windows / Mac
            if hasattr(event, 'delta') and event.delta:
                # event.delta est positif quand on roule vers le haut
                canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
            else:
                # Pour X11: Button-4 (up) / Button-5 (down)
                if event.num == 4:
                    canvas.yview_scroll(-1, "units")
                elif event.num == 5:
                    canvas.yview_scroll(1, "units")

        # Bind global pour permettre le défilement quand la fenêtre a le focus
        canvas.bind_all("<MouseWheel>", _on_mousewheel)
        canvas.bind_all("<Button-4>", _on_mousewheel)
        canvas.bind_all("<Button-5>", _on_mousewheel)

        # Titre
        title_label = ttk.Label(
            main_frame,
            text="🚀 Configuration du Générateur de Rapports",
            font=("Arial", 16, "bold"),
        )
        title_label.pack(pady=(0, 20))

        # Instructions
        instructions = ttk.Label(
            main_frame,
            text="Bienvenue! Configurez les paramètres ci-dessous pour générer vos rapports comptables.",
            font=("Arial", 10),
            wraplength=600,
        )
        instructions.pack(pady=(0, 20))

        # Section 1: Informations générales
        info_frame = ttk.LabelFrame(
            main_frame, text="📋 Informations générales", padding="15"
        )
        info_frame.pack(fill=tk.X, pady=10)

        ttk.Label(
            info_frame, text="Période (ex: Septembre 2025):", font=("Arial", 10)
        ).grid(row=0, column=0, sticky=tk.W, pady=5)
        ttk.Entry(info_frame, textvariable=self.periode_var, width=40).grid(
            row=0, column=1, sticky=(tk.W, tk.E), pady=5, padx=(10, 0)
        )

        ttk.Label(info_frame, text="Cabinet:", font=("Arial", 10)).grid(
            row=1, column=0, sticky=tk.W, pady=5
        )
        ttk.Entry(info_frame, textvariable=self.cabinet_var, width=40).grid(
            row=1, column=1, sticky=(tk.W, tk.E), pady=5, padx=(10, 0)
        )

        ttk.Label(info_frame, text="Client:", font=("Arial", 10)).grid(
            row=2, column=0, sticky=tk.W, pady=5
        )

        # Frame pour le client avec Combobox et info
        client_frame = ttk.Frame(info_frame)
        client_frame.grid(row=2, column=1, sticky=(tk.W, tk.E), pady=5, padx=(10, 0))

        # Combobox pour sélectionner le client
        self.client_combobox = ttk.Combobox(
            client_frame,
            textvariable=self.client_var,
            values=list(self.available_clients.keys()) + ["[Autre - Nouveau client]"],
            width=37,
            state="normal"  # Permet la saisie libre aussi
        )
        self.client_combobox.pack(side=tk.LEFT, fill=tk.X, expand=True)

        # Icône d'info pour expliquer
        info_label = ttk.Label(
            client_frame,
            text="ℹ️",
            font=("Arial", 12),
            cursor="question_arrow"
        )
        info_label.pack(side=tk.LEFT, padx=(5, 0))

        # Tooltip sur l'icône
        self._create_tooltip(
            info_label,
            "Sélectionnez un client existant avec mapping personnalisé,\n"
            "ou saisissez un nouveau nom (utilisera le mapping par défaut)"
        )

        # Événement pour afficher un message quand l'utilisateur sélectionne
        self.client_combobox.bind('<<ComboboxSelected>>', self._on_client_selected)

        info_frame.columnconfigure(1, weight=1)

        # Section 2: Fichier source
        source_frame = ttk.LabelFrame(
            main_frame, text="📁 Fichier source Sage", padding="15"
        )
        source_frame.pack(fill=tk.X, pady=10)

        ttk.Label(
            source_frame,
            text="Sélectionnez le fichier TXT exporté depuis Sage:",
            font=("Arial", 10),
        ).pack(anchor=tk.W, pady=(0, 10))

        file_select_frame = ttk.Frame(source_frame)
        file_select_frame.pack(fill=tk.X)

        ttk.Entry(
            file_select_frame,
            textvariable=self.fichier_sage_var,
            state="readonly",
            width=50,
        ).pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))

        ttk.Button(
            file_select_frame,
            text="📁 Parcourir...",
            command=self._choisir_fichier_sage,
            width=20,
        ).pack(side=tk.RIGHT)

        # Section 3: Dossier de sortie
        output_frame = ttk.LabelFrame(
            main_frame, text="💾 Dossier de sauvegarde", padding="15"
        )
        output_frame.pack(fill=tk.X, pady=10)

        ttk.Label(
            output_frame,
            text="Les rapports générés seront sauvegardés dans ce dossier:",
            font=("Arial", 10),
        ).pack(anchor=tk.W, pady=(0, 10))

        folder_select_frame = ttk.Frame(output_frame)
        folder_select_frame.pack(fill=tk.X)

        ttk.Entry(
            folder_select_frame,
            textvariable=self.dossier_sortie_var,
            state="readonly",
            width=50,
        ).pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))

        ttk.Button(
            folder_select_frame,
            text="📁 Choisir...",
            command=self._choisir_dossier_sortie,
            width=20,
        ).pack(side=tk.RIGHT)

        # Section 4: Options
        options_frame = ttk.LabelFrame(
            main_frame, text="⚙️ Options de génération", padding="15"
        )
        options_frame.pack(fill=tk.X, pady=10)

        ttk.Checkbutton(
            options_frame,
            text="📊 Générer le rapport Excel (.xlsx)",
            variable=self.generer_excel_var,
        ).pack(anchor=tk.W, pady=5)

        ttk.Checkbutton(
            options_frame,
            text="📑 Générer la présentation PowerPoint (.pptx)",
            variable=self.generer_ppt_var,
        ).pack(anchor=tk.W, pady=5)

        # Boutons d'action
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(pady=20)

        ttk.Button(
            button_frame, text="✅ Générer les rapports", command=self.valider, width=30
        ).pack(side=tk.LEFT, padx=5)

        ttk.Button(
            button_frame, text="❌ Annuler", command=self.annuler, width=20
        ).pack(side=tk.LEFT, padx=5)

        # Barre de statut
        self.status_label = ttk.Label(
            main_frame,
            text="Prêt - Veuillez configurer les paramètres ci-dessus",
            relief=tk.SUNKEN,
            anchor=tk.W,
        )
        self.status_label.pack(fill=tk.X, pady=(10, 0))

    def _choisir_fichier_sage(self):
        """Ouvre un dialogue pour sélectionner le fichier Sage"""
        filename = filedialog.askopenfilename(
            title="Sélectionner le fichier Sage (TXT)",
            filetypes=[("Fichiers texte", "*.txt"), ("Tous les fichiers", "*.*")],
        )
        if filename:
            self.fichier_sage_var.set(filename)
            self.status_label.config(text=f"Fichier sélectionné: {Path(filename).name}")

    def _choisir_dossier_sortie(self):
        """Ouvre un dialogue pour sélectionner le dossier de sortie"""
        dossier = filedialog.askdirectory(
            title="Sélectionner le dossier de sauvegarde",
            initialdir=self.dossier_sortie_var.get(),
        )
        if dossier:
            self.dossier_sortie_var.set(dossier)
            self.status_label.config(text=f"Dossier de sortie: {Path(dossier).name}")

    def valider(self):
        """Valide la configuration et lance la génération"""
        # Validations
        if not self.periode_var.get().strip():
            messagebox.showwarning(
                "Attention", "Veuillez renseigner la période du rapport."
            )
            return

        if not self.fichier_sage_var.get():
            messagebox.showwarning(
                "Attention", "Veuillez sélectionner le fichier source Sage."
            )
            return

        if not Path(self.fichier_sage_var.get()).exists():
            messagebox.showerror(
                "Erreur",
                f"Le fichier source n'existe pas:\n{self.fichier_sage_var.get()}",
            )
            return

        if not self.generer_excel_var.get() and not self.generer_ppt_var.get():
            messagebox.showwarning(
                "Attention", "Veuillez sélectionner au moins une option de génération."
            )
            return

        # Confirmation
        options = []
        if self.generer_excel_var.get():
            options.append("Excel")
        if self.generer_ppt_var.get():
            options.append("PowerPoint")

        response = messagebox.askyesno(
            "Confirmation",
            f"Générer les rapports {' et '.join(options)}?\n\n"
            f"Période: {self.periode_var.get()}\n"
            f"Fichier source: {Path(self.fichier_sage_var.get()).name}\n"
            f"Dossier de sortie: {self.dossier_sortie_var.get()}\n\n"
            f"Cette opération peut prendre quelques instants.",
        )

        if response:
            # Déterminer le code client basé sur le nom saisi
            client_name = self.client_var.get()
            client_code = self.available_clients.get(client_name, None)

            # Log pour le debugging
            if client_code:
                logger.info(f"Client '{client_name}' trouvé avec code '{client_code}'")
            else:
                logger.info(f"Client '{client_name}' utilisera le mapping par défaut")

            self.config_data = {
                "periode": self.periode_var.get(),
                "cabinet": self.cabinet_var.get(),
                "client": client_name,
                "client_code": client_code,  # Ajout du code client
                "fichier_sage": self.fichier_sage_var.get(),
                "dossier_sortie": self.dossier_sortie_var.get(),
                "generer_excel": self.generer_excel_var.get(),
                "generer_ppt": self.generer_ppt_var.get(),
            }
            logger.info("Configuration validée par l'utilisateur")
            self.root.quit()
            self.root.destroy()

    def annuler(self):
        """Annule et ferme l'interface"""
        response = messagebox.askyesno(
            "Confirmation",
            "Voulez-vous vraiment annuler?\nAucun rapport ne sera généré.",
        )
        if response:
            self.config_data = None
            logger.info("Configuration annulée par l'utilisateur")
            self.root.quit()
            self.root.destroy()

    def _load_available_clients(self) -> Dict[str, str]:
        """Charge la liste des clients disponibles avec leurs mappings"""
        try:
            clients = get_available_clients()
            logger.info(f"{len(clients)} clients chargés avec mapping personnalisé")
            return clients
        except Exception as e:
            logger.warning(f"Erreur lors du chargement des clients: {e}")
            return {}

    def _on_client_selected(self, event):
        """Appelé quand l'utilisateur sélectionne un client dans la liste"""
        selected_client = self.client_var.get()

        if selected_client == "[Autre - Nouveau client]":
            # Effacer pour que l'utilisateur saisisse
            self.client_var.set("")
            self.status_label.config(
                text="✏️ Saisissez le nom du nouveau client (mapping par défaut sera utilisé)"
            )
        elif selected_client in self.available_clients:
            client_code = self.available_clients[selected_client]
            self.status_label.config(
                text=f"✅ Client '{selected_client}' sélectionné (mapping: {client_code}.json)"
            )
        else:
            self.status_label.config(
                text="⚠️ Client non reconnu - le mapping par défaut sera utilisé"
            )

    def _create_tooltip(self, widget, text):
        """Crée un tooltip simple pour un widget"""
        def on_enter(event):
            # Créer une fenêtre tooltip
            tooltip = tk.Toplevel()
            tooltip.wm_overrideredirect(True)
            tooltip.wm_geometry(f"+{event.x_root+10}+{event.y_root+10}")

            label = ttk.Label(
                tooltip,
                text=text,
                background="#ffffe0",
                relief=tk.SOLID,
                borderwidth=1,
                padding=5
            )
            label.pack()

            # Stocker la référence
            widget.tooltip_window = tooltip

        def on_leave(event):
            # Détruire le tooltip
            if hasattr(widget, 'tooltip_window'):
                widget.tooltip_window.destroy()
                del widget.tooltip_window

        widget.bind('<Enter>', on_enter)
        widget.bind('<Leave>', on_leave)

    def run(self) -> Optional[Dict]:
        """Lance l'interface et retourne la configuration"""
        self.root.mainloop()
        return self.config_data


class CommentaireInterface:
    """Interface graphique complète pour la saisie des commentaires multi-sections"""

    def __init__(
        self,
        periode: str = "",
        cabinet: str = "2BN CONSULTING",
        client: str = "BAMBOO IMMO",
    ):
        self.root = tk.Tk()
        self.root.title("Rapport Comptable - Enrichissement des Commentaires")

        # Calculer une taille dynamique basée sur la résolution de l'écran
        screen_width = self.root.winfo_screenwidth()
        screen_height = self.root.winfo_screenheight()

        # Utiliser 70% de la largeur et 60% de la hauteur de l'écran
        window_width = min(int(screen_width * 0.7), 1200)  # Maximum 1200px
        window_height = min(int(screen_height * 0.6), 700)  # Maximum 700px

        # Centrer la fenêtre
        x = (screen_width // 2) - (window_width // 2)
        y = (screen_height // 2) - (window_height // 2)

        self.root.geometry(f"{window_width}x{window_height}+{x}+{y}")

        self.data = None
        self.current_file = None
        self.text_widgets = {}  # Stocker les widgets de texte pour chaque section

        # Stocker les informations pré-remplies
        self.initial_periode = periode
        self.initial_cabinet = cabinet
        self.initial_client = client

        # Structure des commentaires
        self.sections = {
            "informations": {
                "titre": "Informations Générales",
                "champs": ["periode", "cabinet", "client"],
            },
            "bilan": {
                "titre": "Analyse du Bilan",
                "exemple": self._get_exemple("bilan"),
            },
            "compte_resultat": {
                "titre": "Analyse du Compte de Résultat",
                "exemple": self._get_exemple("compte_resultat"),
            },
            "sig": {
                "titre": "Soldes Intermédiaires de Gestion (SIG)",
                "exemple": self._get_exemple("sig"),
            },
            "suivi_activite": {
                "titre": "Suivi d'Activité Mensuel",
                "exemple": self._get_exemple("suivi_activite"),
            },
            "synthese": {
                "titre": "Synthèse et Recommandations",
                "exemple": self._get_exemple("synthese"),
            },
        }

        self.setup_ui()

    def _get_exemple(self, section_key: str) -> str:
        """Retourne un exemple de commentaire pour une section"""
        exemples = {
            "bilan": """Exemple de commentaire Bilan:

L'actif total s'élève à XX FCFA, en hausse/baisse de XX% par rapport à la période précédente.

Points clés de l'actif:
- Les immobilisations corporelles représentent XX% de l'actif
- Les créances clients sont de XX FCFA
- La trésorerie disponible est de XX FCFA

Au passif:
- Les capitaux propres s'établissent à XX FCFA
- Le résultat net de l'exercice est de XX FCFA
- Les dettes fournisseurs s'élèvent à XX FCFA""",
            "compte_resultat": """Exemple de commentaire Compte de Résultat:

Le chiffre d'affaires de la période s'établit à XX FCFA, soit une variation de XX% par rapport à N-1.

Charges d'exploitation:
- Services extérieurs: XX FCFA
- Charges de personnel: XX FCFA
- Dotations aux amortissements: XX FCFA

Le résultat d'exploitation est de XX FCFA, soit une marge de XX%.

Le résultat net s'établit à XX FCFA.""",
            "sig": """Exemple de commentaire SIG:

Les principaux indicateurs de gestion:

- Marge commerciale: XX FCFA
- Valeur ajoutée: XX FCFA
- Excédent brut d'exploitation (EBE): XX FCFA
- Résultat d'exploitation: XX FCFA
- Résultat net: XX FCFA

Analyse: Les marges restent stables/en progression/en baisse par rapport à la période précédente.""",
            "suivi_activite": """Exemple de commentaire Suivi d'Activité:

Évolution mensuelle de l'activité:

Chiffre d'affaires:
- Point haut du mois: [Mois] avec XX FCFA
- Point bas du mois: [Mois] avec XX FCFA
- Moyenne mensuelle: XX FCFA

Charges:
- Les charges de personnel représentent XX% du total
- Les charges externes sont maîtrisées à XX FCFA/mois en moyenne

Tendances: L'activité est en croissance/stabilité/ralentissement.""",
            "synthese": """Exemple de synthèse et recommandations:

Points positifs:
- [Point positif 1]
- [Point positif 2]

Points d'attention:
- [Point d'attention 1]
- [Point d'attention 2]

Recommandations:
1. [Recommandation 1]
2. [Recommandation 2]
3. [Recommandation 3]

Perspectives pour le mois suivant:
- [Perspective 1]
- [Perspective 2]""",
        }
        return exemples.get(section_key, "")

    def setup_ui(self):
        """Configure l'interface utilisateur avec onglets"""

        # Configuration du style
        style = ttk.Style()
        style.theme_use("clam")

        # Frame principal avec padding
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Configuration du redimensionnement
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(1, weight=1)

        # Titre
        title_label = ttk.Label(
            main_frame,
            text="Saisie des Commentaires du Rapport Comptable",
            font=("Arial", 16, "bold"),
        )
        title_label.grid(row=0, column=0, pady=10)

        # Notebook pour les onglets
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), pady=10)

        # Onglet 1: Informations générales
        self._create_info_tab()

        # Onglets pour chaque section de commentaires
        for section_key in [
            "bilan",
            "compte_resultat",
            "sig",
            "suivi_activite",
            "synthese",
        ]:
            self._create_comment_tab(section_key, self.sections[section_key])

        # Note: L'onglet Configuration a été déplacé dans ConfigurationInterface
        # pour le nouveau flux en 2 étapes

        # Frame pour les boutons
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=2, column=0, pady=10)

        # Boutons d'action avec labels plus clairs
        ttk.Button(
            button_frame, text="📝 Nouveau document", command=self.nouveau, width=22
        ).grid(row=0, column=0, padx=5)

        ttk.Button(
            button_frame, text="📂 Charger commentaires", command=self.charger, width=22
        ).grid(row=0, column=1, padx=5)

        ttk.Button(
            button_frame,
            text="💾 Sauvegarder commentaires",
            command=self.sauvegarder,
            width=25,
        ).grid(row=0, column=2, padx=5)

        ttk.Button(
            button_frame,
            text="✅ Mettre à jour PowerPoint",
            command=self.validate,
            width=25,
        ).grid(row=0, column=3, padx=5)

        # Barre de statut
        self.status_label = ttk.Label(
            main_frame, text="Prêt", relief=tk.SUNKEN, anchor=tk.W
        )
        self.status_label.grid(row=3, column=0, sticky=(tk.W, tk.E))

    def _create_info_tab(self):
        """Crée l'onglet des informations générales"""
        frame = ttk.Frame(self.notebook, padding="20")
        self.notebook.add(frame, text="Informations Générales")

        # Message d'information
        info_label = ttk.Label(
            frame,
            text="Les documents Excel et PowerPoint ont déjà été générés.\n"
            "Vous pouvez maintenant enrichir les commentaires ci-dessous.",
            font=("Arial", 10),
            foreground="#0066cc",
            wraplength=800,
        )
        info_label.grid(
            row=0, column=0, columnspan=2, pady=(0, 20), sticky=(tk.W, tk.E)
        )

        # Période
        ttk.Label(
            frame, text="Période (ex: Septembre 2025):", font=("Arial", 10, "bold")
        ).grid(row=1, column=0, sticky=tk.W, pady=10)
        self.periode_entry = ttk.Entry(frame, width=40, font=("Arial", 10))
        self.periode_entry.insert(0, self.initial_periode)
        self.periode_entry.grid(row=1, column=1, sticky=(tk.W, tk.E), pady=10, padx=10)

        # Cabinet
        ttk.Label(frame, text="Cabinet:", font=("Arial", 10, "bold")).grid(
            row=2, column=0, sticky=tk.W, pady=10
        )
        self.cabinet_entry = ttk.Entry(frame, width=40, font=("Arial", 10))
        self.cabinet_entry.insert(0, self.initial_cabinet)
        self.cabinet_entry.grid(row=2, column=1, sticky=(tk.W, tk.E), pady=10, padx=10)

        # Client
        ttk.Label(frame, text="Client:", font=("Arial", 10, "bold")).grid(
            row=3, column=0, sticky=tk.W, pady=10
        )
        self.client_entry = ttk.Entry(frame, width=40, font=("Arial", 10))
        self.client_entry.insert(0, self.initial_client)
        self.client_entry.grid(row=3, column=1, sticky=(tk.W, tk.E), pady=10, padx=10)

        frame.columnconfigure(1, weight=1)

    def _create_config_tab(self):
        """Crée l'onglet de configuration de génération"""
        frame = ttk.Frame(self.notebook, padding="20")
        self.notebook.add(frame, text="⚙️ Configuration")

        # Titre
        ttk.Label(
            frame,
            text="Configuration de génération des rapports",
            font=("Arial", 12, "bold"),
        ).pack(pady=(0, 20))

        # Section fichier source
        source_frame = ttk.LabelFrame(frame, text="Fichier source Sage", padding="15")
        source_frame.pack(fill=tk.X, pady=10)

        ttk.Label(
            source_frame,
            text="Sélectionnez le fichier TXT exporté depuis Sage:",
            font=("Arial", 10),
        ).grid(row=0, column=0, columnspan=3, sticky=tk.W, pady=(0, 10))

        ttk.Entry(
            source_frame, textvariable=self.fichier_sage_var, width=60, state="readonly"
        ).grid(row=1, column=0, sticky=(tk.W, tk.E), padx=(0, 10))

        ttk.Button(
            source_frame,
            text="📁 Parcourir...",
            command=self._choisir_fichier_sage,
            width=20,
        ).grid(row=1, column=1)

        source_frame.columnconfigure(0, weight=1)

        # Section dossier de sortie
        output_frame = ttk.LabelFrame(
            frame, text="Dossier de sauvegarde des rapports", padding="15"
        )
        output_frame.pack(fill=tk.X, pady=10)

        ttk.Label(
            output_frame,
            text="Les fichiers Excel et PowerPoint seront sauvegardés dans ce dossier:",
            font=("Arial", 10),
        ).grid(row=0, column=0, columnspan=3, sticky=tk.W, pady=(0, 10))

        ttk.Entry(
            output_frame,
            textvariable=self.dossier_sortie_var,
            width=60,
            state="readonly",
        ).grid(row=1, column=0, sticky=(tk.W, tk.E), padx=(0, 10))

        ttk.Button(
            output_frame,
            text="📁 Choisir dossier...",
            command=self._choisir_dossier_sortie,
            width=20,
        ).grid(row=1, column=1)

        output_frame.columnconfigure(0, weight=1)

        # Section options de génération
        options_frame = ttk.LabelFrame(
            frame, text="Options de génération", padding="15"
        )
        options_frame.pack(fill=tk.X, pady=10)

        ttk.Checkbutton(
            options_frame,
            text="📊 Générer le rapport Excel (.xlsx)",
            variable=self.generer_excel_var,
            onvalue=True,
            offvalue=False,
        ).pack(anchor=tk.W, pady=5)

        ttk.Checkbutton(
            options_frame,
            text="📑 Générer la présentation PowerPoint (.pptx)",
            variable=self.generer_ppt_var,
            onvalue=True,
            offvalue=False,
        ).pack(anchor=tk.W, pady=5)

        # Instructions
        info_frame = ttk.Frame(frame)
        info_frame.pack(fill=tk.BOTH, expand=True, pady=20)

        instructions_text = """
Instructions d'utilisation:

1. Sélectionnez le fichier TXT exporté depuis Sage
2. Choisissez le dossier où sauvegarder les rapports générés
3. Remplissez les informations générales (onglet "Informations Générales")
4. Saisissez vos commentaires dans chaque section
5. Utilisez les boutons de formatage (Gras, Italique, Puces) pour mettre en forme vos textes
6. Sauvegardez vos commentaires régulièrement
7. Cliquez sur "✅ Générer les rapports" pour créer les fichiers finaux

Raccourcis clavier:
• Ctrl+B: Mettre en gras
• Ctrl+I: Mettre en italique
        """

        info_text = tk.Text(
            info_frame,
            wrap=tk.WORD,
            height=15,
            font=("Arial", 10),
            relief=tk.FLAT,
            background="#f0f0f0",
        )
        info_text.pack(fill=tk.BOTH, expand=True)
        info_text.insert("1.0", instructions_text.strip())
        info_text.config(state=tk.DISABLED)

    def _choisir_fichier_sage(self):
        """Ouvre un dialogue pour sélectionner le fichier Sage"""
        filename = filedialog.askopenfilename(
            title="Sélectionner le fichier Sage (TXT)",
            filetypes=[("Fichiers texte", "*.txt"), ("Tous les fichiers", "*.*")],
        )
        if filename:
            self.fichier_sage_var.set(filename)
            self.status_label.config(text=f"Fichier source: {Path(filename).name}")

    def _choisir_dossier_sortie(self):
        """Ouvre un dialogue pour sélectionner le dossier de sortie"""
        dossier = filedialog.askdirectory(
            title="Sélectionner le dossier de sauvegarde",
            initialdir=self.dossier_sortie_var.get(),
        )
        if dossier:
            self.dossier_sortie_var.set(dossier)
            self.status_label.config(text=f"Dossier de sortie: {Path(dossier).name}")

    def _create_comment_tab(self, section_key: str, section_info: dict):
        """Crée un onglet pour une section de commentaires"""
        frame = ttk.Frame(self.notebook, padding="20")
        self.notebook.add(frame, text=section_info["titre"])

        # Barre d'outils de formatage
        toolbar = ttk.Frame(frame)
        toolbar.pack(fill=tk.X, pady=(0, 5))

        ttk.Label(toolbar, text="Formatage:", font=("Arial", 9, "bold")).pack(
            side=tk.LEFT, padx=5
        )

        # Boutons de formatage
        ttk.Button(
            toolbar,
            text="Gras (Ctrl+B)",
            command=lambda: self._toggle_bold(section_key),
            width=15,
        ).pack(side=tk.LEFT, padx=2)

        ttk.Button(
            toolbar,
            text="Italique (Ctrl+I)",
            command=lambda: self._toggle_italic(section_key),
            width=18,
        ).pack(side=tk.LEFT, padx=2)

        ttk.Button(
            toolbar,
            text="• Liste à puces",
            command=lambda: self._insert_bullet(section_key),
            width=15,
        ).pack(side=tk.LEFT, padx=2)

        # Instructions
        instructions = ttk.Label(
            frame,
            text=f"Saisissez vos commentaires pour la section '{section_info['titre']}' ci-dessous:",
            wraplength=900,
            font=("Arial", 10),
        )
        instructions.pack(pady=(5, 10))

        # Créer une frame pour le texte avec des tags
        text_frame = tk.Frame(frame)
        text_frame.pack(fill=tk.BOTH, expand=True)

        # Zone de texte avec support des tags
        text_widget = tk.Text(
            text_frame,
            wrap=tk.WORD,
            font=("Arial", 10),
            width=100,
            height=25,
            undo=True,
        )

        # Scrollbar
        scrollbar = ttk.Scrollbar(text_frame, command=text_widget.yview)
        text_widget.config(yscrollcommand=scrollbar.set)

        text_widget.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        # Configuration des tags pour le formatage
        bold_font = tkfont.Font(family="Arial", size=10, weight="bold")
        italic_font = tkfont.Font(family="Arial", size=10, slant="italic")
        bold_italic_font = tkfont.Font(
            family="Arial", size=10, weight="bold", slant="italic"
        )

        text_widget.tag_configure("bold", font=bold_font)
        text_widget.tag_configure("italic", font=italic_font)
        text_widget.tag_configure("bold_italic", font=bold_italic_font)
        text_widget.tag_configure("placeholder", foreground="gray")

        # Insérer l'exemple en gris
        exemple = section_info.get("exemple", "")
        if exemple:
            text_widget.insert("1.0", exemple)
            text_widget.tag_add("placeholder", "1.0", "end")

            # Effacer l'exemple au premier clic
            def on_focus(event, widget=text_widget, ex=exemple):
                if widget.tag_ranges("placeholder"):
                    widget.delete("1.0", tk.END)
                    widget.tag_remove("placeholder", "1.0", "end")

            text_widget.bind("<FocusIn>", on_focus)

        # Raccourcis clavier
        text_widget.bind("<Control-b>", lambda e: self._toggle_bold(section_key))
        text_widget.bind("<Control-i>", lambda e: self._toggle_italic(section_key))

        # Stocker le widget
        self.text_widgets[section_key] = text_widget

    def _toggle_bold(self, section_key: str):
        """Active/désactive le gras pour la sélection"""
        text_widget = self.text_widgets[section_key]
        try:
            # Récupérer la sélection
            sel_start = text_widget.index(tk.SEL_FIRST)
            sel_end = text_widget.index(tk.SEL_LAST)

            # Vérifier si déjà en gras
            current_tags = text_widget.tag_names(sel_start)

            if "bold_italic" in current_tags:
                # Passer de gras+italique à italique
                text_widget.tag_remove("bold_italic", sel_start, sel_end)
                text_widget.tag_add("italic", sel_start, sel_end)
            elif "bold" in current_tags:
                # Enlever le gras
                text_widget.tag_remove("bold", sel_start, sel_end)
            elif "italic" in current_tags:
                # Passer de italique à gras+italique
                text_widget.tag_remove("italic", sel_start, sel_end)
                text_widget.tag_add("bold_italic", sel_start, sel_end)
            else:
                # Ajouter le gras
                text_widget.tag_add("bold", sel_start, sel_end)
        except tk.TclError:
            pass  # Pas de sélection

        return "break"

    def _toggle_italic(self, section_key: str):
        """Active/désactive l'italique pour la sélection"""
        text_widget = self.text_widgets[section_key]
        try:
            sel_start = text_widget.index(tk.SEL_FIRST)
            sel_end = text_widget.index(tk.SEL_LAST)

            current_tags = text_widget.tag_names(sel_start)

            if "bold_italic" in current_tags:
                # Passer de gras+italique à gras
                text_widget.tag_remove("bold_italic", sel_start, sel_end)
                text_widget.tag_add("bold", sel_start, sel_end)
            elif "italic" in current_tags:
                # Enlever l'italique
                text_widget.tag_remove("italic", sel_start, sel_end)
            elif "bold" in current_tags:
                # Passer de gras à gras+italique
                text_widget.tag_remove("bold", sel_start, sel_end)
                text_widget.tag_add("bold_italic", sel_start, sel_end)
            else:
                # Ajouter l'italique
                text_widget.tag_add("italic", sel_start, sel_end)
        except tk.TclError:
            pass

        return "break"

    def _insert_bullet(self, section_key: str):
        """Insère une puce au début de la ligne courante"""
        text_widget = self.text_widgets[section_key]

        # Obtenir la position du curseur
        cursor_pos = text_widget.index(tk.INSERT)
        line_start = text_widget.index(f"{cursor_pos} linestart")

        # Insérer la puce
        text_widget.insert(line_start, "• ")

        return "break"

    def nouveau(self):
        """Crée un nouveau fichier de commentaires"""
        if messagebox.askyesno(
            "Nouveau",
            "Créer un nouveau fichier?\nLes modifications non sauvegardées seront perdues.",
        ):
            self.current_file = None
            self.periode_entry.delete(0, tk.END)
            self.cabinet_entry.delete(0, tk.END)
            self.cabinet_entry.insert(0, "2BN CONSULTING")
            self.client_entry.delete(0, tk.END)
            self.client_entry.insert(0, "BAMBOO IMMO")

            for text_widget in self.text_widgets.values():
                text_widget.delete("1.0", tk.END)
                text_widget.config(fg="black")

            self.status_label.config(text="Nouveau fichier créé")
            logger.info("Nouveau fichier de commentaires créé")

    def charger(self):
        """Charge un fichier de commentaires"""
        filename = filedialog.askopenfilename(
            title="Charger les commentaires",
            filetypes=[
                ("Fichiers texte", "*.txt"),
                ("Fichiers JSON (ancien format)", "*.json"),
                ("Tous les fichiers", "*.*"),
            ],
        )

        if filename:
            try:
                # Déterminer le format du fichier
                if filename.endswith(".json"):
                    data = self._charger_json(filename)
                else:
                    data = self._charger_texte(filename)

                # Charger les infos générales
                self.periode_entry.delete(0, tk.END)
                self.periode_entry.insert(0, data.get("periode", ""))

                self.cabinet_entry.delete(0, tk.END)
                self.cabinet_entry.insert(0, data.get("cabinet", "2BN CONSULTING"))

                self.client_entry.delete(0, tk.END)
                self.client_entry.insert(0, data.get("client", "BAMBOO IMMO"))

                # Charger les commentaires avec formatage
                for section_key, text_widget in self.text_widgets.items():
                    text_widget.delete("1.0", tk.END)
                    text_widget.tag_remove("placeholder", "1.0", "end")

                    if section_key in data:
                        section_data = data[section_key]
                        if isinstance(section_data, dict):
                            commentaire = section_data.get("commentaire", "")
                            formatting = section_data.get("formatting", [])
                        else:
                            commentaire = section_data
                            formatting = []

                        if commentaire:
                            text_widget.insert("1.0", commentaire)

                            # Appliquer le formatage
                            for fmt in formatting:
                                start_idx = fmt.get("start", "1.0")
                                end_idx = fmt.get("end", "1.0")
                                tag = fmt.get("tag", "")
                                if tag:
                                    text_widget.tag_add(tag, start_idx, end_idx)

                self.current_file = filename
                self.status_label.config(text=f"Fichier chargé: {Path(filename).name}")
                logger.info(f"Commentaires chargés depuis: {filename}")

            except Exception as e:
                messagebox.showerror(
                    "Erreur", f"Impossible de charger le fichier:\n{str(e)}"
                )
                logger.error(f"Erreur lors du chargement: {e}")

    def _charger_json(self, filename: str) -> Dict:
        """Charge un fichier JSON (ancien format)"""
        with open(filename, "r", encoding="utf-8") as f:
            return json.load(f)

    def _charger_texte(self, filename: str) -> Dict:
        """Charge un fichier texte (nouveau format)"""
        data = {"periode": "", "cabinet": "2BN CONSULTING", "client": "BAMBOO IMMO"}

        with open(filename, "r", encoding="utf-8") as f:
            contenu = f.read()

        # Parser le contenu
        current_section = None
        lines = contenu.split("\n")

        for line in lines:
            # Informations générales
            if line.startswith("PÉRIODE:"):
                data["periode"] = line.replace("PÉRIODE:", "").strip()
            elif line.startswith("CABINET:"):
                data["cabinet"] = line.replace("CABINET:", "").strip()
            elif line.startswith("CLIENT:"):
                data["client"] = line.replace("CLIENT:", "").strip()

            # Sections
            elif line.startswith("=== BILAN ==="):
                current_section = "bilan"
                data[current_section] = {"commentaire": "", "formatting": []}
            elif line.startswith("=== COMPTE DE RÉSULTAT ==="):
                current_section = "compte_resultat"
                data[current_section] = {"commentaire": "", "formatting": []}
            elif line.startswith("=== SIG ==="):
                current_section = "sig"
                data[current_section] = {"commentaire": "", "formatting": []}
            elif line.startswith("=== SUIVI D'ACTIVITÉ ==="):
                current_section = "suivi_activite"
                data[current_section] = {"commentaire": "", "formatting": []}
            elif line.startswith("=== SYNTHÈSE ==="):
                current_section = "synthese"
                data[current_section] = {"commentaire": "", "formatting": []}

            # Contenu de section
            elif current_section and line.startswith("---"):
                continue  # Séparateur
            elif current_section and not line.startswith("==="):
                if data[current_section]["commentaire"]:
                    data[current_section]["commentaire"] += "\n" + line
                else:
                    data[current_section]["commentaire"] = line

        # Nettoyer les commentaires
        for section_key in [
            "bilan",
            "compte_resultat",
            "sig",
            "suivi_activite",
            "synthese",
        ]:
            if section_key in data:
                data[section_key]["commentaire"] = data[section_key][
                    "commentaire"
                ].strip()

        return data

    def sauvegarder(self):
        """Sauvegarde les commentaires"""
        if self.current_file:
            self._sauvegarder_vers_fichier(self.current_file)
        else:
            self.sauvegarder_sous()

    def sauvegarder_sous(self):
        """Sauvegarde les commentaires avec un nouveau nom"""
        periode = self.periode_entry.get().replace(" ", "_").replace("/", "_")
        default_name = f"commentaires_{periode}.txt" if periode else "commentaires.txt"

        filename = filedialog.asksaveasfilename(
            title="Sauvegarder les commentaires",
            defaultextension=".txt",
            initialfile=default_name,
            filetypes=[
                ("Fichiers texte", "*.txt"),
                ("Fichiers JSON", "*.json"),
                ("Tous les fichiers", "*.*"),
            ],
        )

        if filename:
            self._sauvegarder_vers_fichier(filename)
            self.current_file = filename

    def _sauvegarder_vers_fichier(self, filename: str):
        """Sauvegarde vers un fichier spécifique"""
        try:
            # Choisir le format selon l'extension
            if filename.endswith(".json"):
                self._sauvegarder_json(filename)
            else:
                self._sauvegarder_texte(filename)

            self.status_label.config(text=f"Sauvegardé: {Path(filename).name}")
            messagebox.showinfo("Succès", "Commentaires sauvegardés avec succès!")
            logger.info(f"Commentaires sauvegardés vers: {filename}")

        except Exception as e:
            messagebox.showerror("Erreur", f"Impossible de sauvegarder:\n{str(e)}")
            logger.error(f"Erreur lors de la sauvegarde: {e}")

    def _sauvegarder_json(self, filename: str):
        """Sauvegarde au format JSON (ancien format, pour compatibilité)"""
        data = self._collecter_commentaires()
        data["date_modification"] = datetime.now().isoformat()

        with open(filename, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    def _sauvegarder_texte(self, filename: str):
        """Sauvegarde au format texte lisible"""
        data = self._collecter_commentaires()

        with open(filename, "w", encoding="utf-8") as f:
            # En-tête
            f.write("=" * 80 + "\n")
            f.write("RAPPORT COMPTABLE - COMMENTAIRES\n")
            f.write("=" * 80 + "\n\n")

            # Informations générales
            f.write("INFORMATIONS GÉNÉRALES\n")
            f.write("-" * 80 + "\n")
            f.write(f"PÉRIODE: {data.get('periode', '')}\n")
            f.write(f"CABINET: {data.get('cabinet', '')}\n")
            f.write(f"CLIENT: {data.get('client', '')}\n")
            f.write(
                f"DATE DE MODIFICATION: {datetime.now().strftime('%d/%m/%Y %H:%M')}\n"
            )
            f.write("\n\n")

            # Sections
            sections = [
                ("bilan", "BILAN"),
                ("compte_resultat", "COMPTE DE RÉSULTAT"),
                ("sig", "SIG"),
                ("suivi_activite", "SUIVI D'ACTIVITÉ"),
                ("synthese", "SYNTHÈSE"),
            ]

            for section_key, section_titre in sections:
                if section_key in data:
                    f.write("=" * 80 + "\n")
                    f.write(f"=== {section_titre} ===\n")
                    f.write("=" * 80 + "\n\n")

                    commentaire = data[section_key].get("commentaire", "")
                    if commentaire:
                        f.write(commentaire)
                    else:
                        f.write("(Aucun commentaire)")

                    f.write("\n\n\n")

            # Pied de page
            f.write("=" * 80 + "\n")
            f.write("FIN DU DOCUMENT\n")
            f.write("=" * 80 + "\n")

    def _collecter_commentaires(self) -> Dict:
        """Collecte tous les commentaires saisis"""
        data = {
            "periode": self.periode_entry.get(),
            "cabinet": self.cabinet_entry.get(),
            "client": self.client_entry.get(),
        }

        for section_key, text_widget in self.text_widgets.items():
            # Ne pas sauvegarder si c'est le placeholder
            if text_widget.tag_ranges("placeholder"):
                contenu = ""
                formatting = []
            else:
                contenu = text_widget.get("1.0", "end-1c").strip()

                # Collecter les informations de formatage
                formatting = []
                for tag_name in ["bold", "italic", "bold_italic"]:
                    ranges = text_widget.tag_ranges(tag_name)
                    for i in range(0, len(ranges), 2):
                        if i + 1 < len(ranges):
                            formatting.append(
                                {
                                    "tag": tag_name,
                                    "start": str(ranges[i]),
                                    "end": str(ranges[i + 1]),
                                }
                            )

            data[section_key] = {
                "titre": self.sections[section_key]["titre"],
                "commentaire": contenu,
                "formatting": formatting,
            }

        return data

    def validate(self):
        """Valide et ferme l'interface"""
        # Vérifier que la période est renseignée
        if not self.periode_entry.get().strip():
            messagebox.showwarning(
                "Attention", "Veuillez renseigner la période du rapport."
            )
            self.notebook.select(0)  # Aller à l'onglet Informations
            self.periode_entry.focus()
            return

        # Confirmer l'enrichissement des commentaires
        response = messagebox.askyesno(
            "Confirmation",
            "Mettre à jour le PowerPoint avec les commentaires enrichis?\n\n"
            "Les commentaires seront intégrés dans la présentation.",
        )

        if response:
            self.data = self._collecter_commentaires()
            logger.info("Commentaires validés pour mise à jour")
            self.root.quit()
            self.root.destroy()

    def run(self) -> Optional[Dict]:
        """Lance l'interface et retourne les données saisies"""
        self.root.mainloop()
        return self.data


def collect_configuration() -> Optional[Dict]:
    """
    Affiche l'interface de configuration initiale

    Returns:
        Dictionnaire avec la configuration ou None si annulé
    """
    logger.info("Lancement de l'interface de configuration")

    try:
        interface = ConfigurationInterface()
        config = interface.run()

        if config:
            logger.info("Configuration collectée avec succès")

        return config

    except Exception as e:
        logger.error(f"Erreur dans l'interface de configuration: {e}")
        messagebox.showerror("Erreur", f"Une erreur s'est produite:\n{e}")
        return None


def collect_user_input() -> Optional[Dict]:
    """
    Affiche l'interface de saisie et collecte les commentaires utilisateur

    Returns:
        Dictionnaire avec les commentaires ou None si annulé
    """
    logger.info("Lancement de l'interface de saisie des commentaires")

    try:
        interface = CommentaireInterface()
        data = interface.run()

        if data:
            logger.info("Commentaires collectés avec succès")

        return data

    except Exception as e:
        logger.error(f"Erreur dans l'interface utilisateur: {e}")
        messagebox.showerror("Erreur", f"Une erreur s'est produite:\n{e}")
        return None


def collect_comments_for_existing_reports(
    periode: str,
    cabinet: str,
    client: str,
    excel_path: Optional[str] = None,
    ppt_path: Optional[str] = None,
) -> Optional[Dict]:
    """
    Affiche l'interface pour enrichir des rapports déjà générés

    Args:
        periode: Période du rapport
        cabinet: Nom du cabinet
        client: Nom du client
        excel_path: Chemin du fichier Excel généré
        ppt_path: Chemin du fichier PowerPoint généré

    Returns:
        Dictionnaire avec les commentaires ou None si annulé
    """
    logger.info("Lancement de l'interface d'enrichissement des commentaires")

    try:
        # Créer l'interface avec les informations pré-remplies
        interface = CommentaireInterface(
            periode=periode, cabinet=cabinet, client=client
        )

        data = interface.run()

        if data:
            logger.info("Commentaires enrichis avec succès")

        return data

    except Exception as e:
        logger.error(f"Erreur dans l'interface d'enrichissement: {e}")
        messagebox.showerror("Erreur", f"Une erreur s'est produite:\n{e}")
        return None


def load_comments_from_file(file_path: str) -> Optional[Dict]:
    """
    Charge des commentaires sauvegardés depuis un fichier JSON

    Args:
        file_path: Chemin vers le fichier JSON

    Returns:
        Dictionnaire des commentaires ou None
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        logger.info(f"Commentaires chargés depuis {file_path}")
        return data

    except Exception as e:
        logger.error(f"Erreur lors du chargement des commentaires: {e}")
        return None


def save_comments_to_file(data: Dict, file_path: str):
    """
    Sauvegarde les commentaires dans un fichier JSON

    Args:
        data: Dictionnaire des commentaires
        file_path: Chemin vers le fichier JSON
    """
    try:
        data["date_modification"] = datetime.now().isoformat()

        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        logger.info(f"Commentaires sauvegardés vers {file_path}")

    except Exception as e:
        logger.error(f"Erreur lors de la sauvegarde des commentaires: {e}")
        raise


if __name__ == "__main__":
    # Test de l'interface
    logging.basicConfig(
        level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
    )
    print("=" * 80)
    print("TEST MODULE 4 - INTERFACE UTILISATEUR")
    print("=" * 80)
    print()
    print("Lancement de l'interface de saisie des commentaires...")
    print()

    data = collect_user_input()

    if data:
        print()
        print("=" * 80)
        print("COMMENTAIRES COLLECTÉS:")
        print("=" * 80)
        print()
        print(f"Période: {data.get('periode')}")
        print(f"Cabinet: {data.get('cabinet')}")
        print(f"Client: {data.get('client')}")
        print()

        for section in [
            "bilan",
            "compte_resultat",
            "sig",
            "suivi_activite",
            "synthese",
        ]:
            if section in data:
                print(f"\n{data[section]['titre']}:")
                print("-" * 40)
                commentaire = data[section]["commentaire"]
                if commentaire:
                    # Afficher les 100 premiers caractères
                    preview = (
                        commentaire[:100] + "..."
                        if len(commentaire) > 100
                        else commentaire
                    )
                    print(preview)
                else:
                    print("(Aucun commentaire)")

        print()
        print("=" * 80)
        print("✅ Interface terminée avec succès!")
    else:
        print()
        print("❌ Saisie annulée par l'utilisateur")
        print()
