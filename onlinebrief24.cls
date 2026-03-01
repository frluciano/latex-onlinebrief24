\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{onlinebrief24}[2026/03/02 Precision Layout Class with Guides]

% --- Basis: KOMA-Script Briefklasse ---
\LoadClass[fontsize=11pt, parskip=half]{scrlttr2}

% --- Pakete ---
\RequirePackage{geometry}
\RequirePackage{fontspec}
\RequirePackage{eso-pic}
\RequirePackage{xcolor}
\RequirePackage{calc}
\RequirePackage{tikz} % Für präzise Zeichnungen im Guides-Modus
\usetikzlibrary{calc, arrows.meta}

% --- Schriftart: Arial-Ersatz ---
\setmainfont{Arial}[Ligatures=TeX]
\setsansfont{Arial}[Ligatures=TeX]

% --- KOMA-Script Deaktivierung ---
\KOMAoptions{
  addrfield=false,
  firsthead=false,
  firstfoot=false,
  foldmarks=false
}

% --- Seitenlayout ---
\geometry{
  paper=a4paper,
  top=110mm,
  bottom=25mm,
  left=25mm,
  right=20mm,
  footskip=10mm
}

% --- Datenspeicher ---
\newcommand{\@obb@return}{}
\newcommand{\@obb@recipient}{}
\newcommand{\setreturnaddress}[1]{\renewcommand{\@obb@return}{#1}}
\newcommand{\setrecipient}[1]{\renewcommand{\@obb@recipient}{#1}}

% Patch letter environment
\let\@obb@oldletter\letter
\renewcommand{\letter}[1]{%
  \@obb@oldletter{}%
}

% --- Optionen ---
\newif\if@guidesmode
\DeclareOption{guides}{\@guidesmodetrue}
\DeclareOption{final}{\@guidesmodefalse}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrlttr2}}
\ProcessOptions\relax

% --- Layout-Zeichnung ---
\AddToShipoutPictureBG{%
  \setlength{\unitlength}{1mm}%
  
  % --- Inhalt (immer sichtbar) ---
  
  % Zone 1: Absender (45mm von oben)
  \put(20, 250){%
    \parbox[b][2mm][c]{85mm}{%
      \fontsize{8pt}{9pt}\sffamily\selectfont
      \if@guidesmode\color{darkgray}\fi
      \@obb@return
    }%
  }%

  % Zone 3: Empfänger (67mm von oben)
  \put(20, 210){%
    \parbox[b][20mm][t]{85mm}{%
      \fontsize{11pt}{13pt}\sffamily\selectfont
      \@obb@recipient
    }%
  }%
  
  % Falzmarken (immer sichtbar, aber dezent)
  \put(5, 192){\line(1,0){5}}
  \put(5, 92){\line(1,0){5}}

  % Datum & Ort (manuell platziert)
  \put(110, 199){%
    \parbox[b][5mm][r]{80mm}{%
      \fontsize{11pt}{13pt}\sffamily\selectfont
      \usekomavar{place}\Ifkomavarempty{place}{}{, }\usekomavar{date}%
    }%
  }%

  % --- Guides Modus (Technische Zeichnung) ---
  \if@guidesmode
    \begin{tikzpicture}[remember picture, overlay]
      % Koordinaten-Ursprung oben links definieren für einfacheres Denken
      \coordinate (TL) at (current page.north west);
      
      % Stile
      \tikzset{
        guide line/.style={draw=blue!50, thin},
        guide text/.style={font=\fontsize{7}{8}\sffamily, text=blue!70, inner sep=1pt},
        dim line/.style={draw=red!70, thin, |<->|},
        dim text/.style={midway, fill=white, font=\fontsize{6}{7}\sffamily, text=red!70, inner sep=1pt}
      }

      % --- Fenster-Rahmen ---
      % Start bei (20mm, -45mm)
      % Breite 72mm (Standard DIN Fensterbreite ist eigentlich 85mm, aber Spezifikation sagt 72mm)
      % Wir zeichnen den Rahmen basierend auf den Zonen.
      
      % Zone 1 (Absender): 45mm bis 47mm
      \draw[guide line] ($(TL)+(20mm, -45mm)$) rectangle ++(72mm, -2mm);
      \node[guide text, anchor=west] at ($(TL)+(92mm, -46mm)$) {Zone 1 (Absender)};
      
      % Zone 2 (Sperrzone): 47mm bis 67mm
      \draw[guide line, fill=red!5] ($(TL)+(20mm, -47mm)$) rectangle ++(72mm, -20mm);
      \node[guide text, anchor=west] at ($(TL)+(92mm, -57mm)$) {Zone 2 (Sperrzone/Codes)};
      
      % Zone 3 (Empfänger): 67mm bis 87mm
      \draw[guide line] ($(TL)+(20mm, -67mm)$) rectangle ++(72mm, -20mm);
      \node[guide text, anchor=west] at ($(TL)+(92mm, -77mm)$) {Zone 3 (Empfänger)};
      
      % --- Maßpfeile (Links vom Fenster) ---
      
      % Offset 45mm (Start Fenster)
      \draw[dim line] ($(TL)+(15mm, 0)$) -- ($(TL)+(15mm, -45mm)$) node[dim text, rotate=90] {45mm};
      
      % Höhe Zone 1 (2mm) - Text nach links verschoben wegen Platzmangel
      \draw[dim line] ($(TL)+(15mm, -45mm)$) -- ($(TL)+(15mm, -47mm)$) node[midway, left=1mm, rotate=90, font=\fontsize{5}{6}\sffamily, text=red!70] {2mm};
      
      % Höhe Zone 2 (20mm)
      \draw[dim line] ($(TL)+(15mm, -47mm)$) -- ($(TL)+(15mm, -67mm)$) node[dim text, rotate=90] {20mm};
      
      % Höhe Zone 3 (20mm)
      \draw[dim line] ($(TL)+(15mm, -67mm)$) -- ($(TL)+(15mm, -87mm)$) node[dim text, rotate=90] {20mm};
      
      % Horizontaler Abstand (20mm)
      \draw[dim line] ($(TL)+(0, -40mm)$) -- ($(TL)+(20mm, -40mm)$) node[dim text] {20mm};
      
      % Fensterbreite (72mm)
      \draw[dim line] ($(TL)+(20mm, -40mm)$) -- ($(TL)+(92mm, -40mm)$) node[dim text] {72mm};

      % --- Falzmarken Hinweise (Text am Ende der Linie) ---
      \draw[red!70, thin, <-] ($(TL)+(6mm, -105mm)$) -- ($(TL)+(15mm, -105mm)$) node[anchor=west, rotate=90, font=\fontsize{6}{7}\sffamily, text=red!70, inner sep=1pt] {1. Falz (105mm)};
      
      \draw[red!70, thin, <-] ($(TL)+(6mm, -205mm)$) -- ($(TL)+(15mm, -205mm)$) node[anchor=west, rotate=90, font=\fontsize{6}{7}\sffamily, text=red!70, inner sep=1pt] {2. Falz (205mm)};
      
      % --- Textbeginn Linie (Nur angedeutet, nicht volle Breite) ---
      \draw[guide line, dashed] ($(TL)+(20mm, -110mm)$) -- ($(TL)+(100mm, -110mm)$);
      \node[guide text, anchor=south west] at ($(TL)+(25mm, -110mm)$) {Textbeginn (110mm)};

    \end{tikzpicture}
  \fi
}

% --- Betreff manuell setzen ---
\let\@obb@oldopening\opening
\renewcommand{\opening}[1]{%
  \Ifkomavarempty{subject}{}{%
    {\bfseries\sffamily\usekomavar{subject}}\par
    \vspace{1em}%
  }%
  \@obb@oldopening{#1}%
}

\endinput
