\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{onlinebrief24}[2026/03/02 Precision Layout Class with Guides]

% --- Basis: KOMA-Script Briefklasse ---
\LoadClass[fontsize=11pt, parskip=half]{scrlttr2}

% --- Pakete ---
\RequirePackage[ngerman]{babel} % Deutsche Spracheinstellungen (Datum, Trennung)
\RequirePackage{geometry}
\RequirePackage{fontspec}
\RequirePackage{eso-pic}
\RequirePackage{xcolor}
\RequirePackage{calc}
\RequirePackage{tikz} % Für präzise Zeichnungen im Guides-Modus
\usetikzlibrary{calc, arrows.meta}
\RequirePackage{etoolbox} % Für \ifdefempty

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
\newcommand{\@obb@subject}{}
\newcommand{\@obb@date}{\today}
\newcommand{\@obb@place}{}
\newcommand{\@obb@fromfirstname}{}
\newcommand{\@obb@fromlastname}{}
\newcommand{\@obb@fromaddress}{}
\newcommand{\@obb@fromphone}{}
\newcommand{\@obb@fromemail}{}
\newcommand{\@obb@fromweb}{}
\newcommand{\@obb@fromlinkedin}{}
\newcommand{\@obb@fromlandline}{}

\newcommand{\setreturnaddress}[1]{\renewcommand{\@obb@return}{#1}}
\newcommand{\setrecipient}[1]{\renewcommand{\@obb@recipient}{#1}}
\newcommand{\setsubject}[1]{\renewcommand{\@obb@subject}{#1}}
\newcommand{\setdate}[1]{\renewcommand{\@obb@date}{#1}}
\newcommand{\setplace}[1]{\renewcommand{\@obb@place}{#1}}
\newcommand{\setfromname}[1]{\renewcommand{\@obb@fromname}{#1}} % Legacy
\newcommand{\setfromfirstname}[1]{\renewcommand{\@obb@fromfirstname}{#1}}
\newcommand{\setfromlastname}[1]{\renewcommand{\@obb@fromlastname}{#1}}
\newcommand{\setfromaddress}[1]{\renewcommand{\@obb@fromaddress}{#1}}
\newcommand{\setfromphone}[1]{\renewcommand{\@obb@fromphone}{#1}}
\newcommand{\setfromemail}[1]{\renewcommand{\@obb@fromemail}{#1}}
\newcommand{\setfromweb}[1]{\renewcommand{\@obb@fromweb}{#1}}
\newcommand{\setfromlinkedin}[1]{\renewcommand{\@obb@fromlinkedin}{#1}}
\newcommand{\setfromlandline}[1]{\renewcommand{\@obb@fromlandline}{#1}}

% Patch letter environment
\let\@obb@oldletter\letter
\renewcommand{\letter}[1]{%
  \@obb@oldletter{}%
}

% --- Optionen ---
\newif\if@guidesmode
\newif\if@modernstyle
\newif\if@footercenter
\DeclareOption{guides}{\@guidesmodetrue}
\DeclareOption{modern}{\@modernstyletrue}
\DeclareOption{footercenter}{\@footercentertrue}
\DeclareOption{basic}{\@guidesmodefalse}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrlttr2}}
\ProcessOptions\relax

% --- Bedingtes Laden für den modernen Stil ---
\if@modernstyle
  \RequirePackage[default, light, semibold]{sourcesanspro}
  \RequirePackage{marvosym}
  \RequirePackage{fontawesome}
  \definecolor{color2}{rgb}{0.45,0.45,0.45}
\fi

% --- Layout-Zeichnung ---
\AddToShipoutPictureBG{%
  \setlength{\unitlength}{1mm}%
  
  % --- Inhalt (immer sichtbar) ---
  
      % Zone 1: Absender (45mm von oben)
      % Linksbündig bei 25mm (5mm Einzug im 20mm Fenster)
      \put(25, 250){%
        \parbox[b][2mm][c]{80mm}{%
          \fontsize{8pt}{9pt}\sffamily\selectfont
          \if@guidesmode\color{darkgray}\fi
          \@obb@return
        }%
      }%
      % Unterstrich für Zone 1
      \put(25, 248){\line(1,0){80}}

  % Zone 3: Empfänger (67mm von oben)
  % Linksbündig bei 25mm (5mm Einzug im 20mm Fenster)
  \put(25, 210){%
    \parbox[b][20mm][t]{80mm}{%
      \fontsize{11pt}{13pt}\sffamily\selectfont
      \@obb@recipient
    }%
  }%
  
  % Falzmarken (immer sichtbar, aber dezent)
  \put(5, 192){\line(1,0){5}}
  \put(5, 92){\line(1,0){5}}

  % --- Moderner Stil (Kopf- und Fußzeile) ---
  \if@modernstyle
    % Kopfzeile: Name
    \put(25, 270){%
        \parbox[t][15mm][t]{\paperwidth-50mm}{%
            \raggedleft
            \fontsize{18pt}{20pt}\sffamily\bfseries
            \color{color2!50}\@obb@fromfirstname\ \color{color2}\@obb@fromlastname
            \ifdefempty{\@obb@fromaddress}{}{\\[4pt]
              \fontsize{10pt}{12pt}\sffamily\color{color2!50}
              \@obb@fromaddress
            }
        }%
    }%
    
    % Fußzeile: Kontaktdaten
    \put(25, 15){%
      \parbox[b][10mm][b]{\textwidth}{%
        \if@footercenter\centering\else\raggedleft\fi
        \footnotesize\sffamily\color{color2}%
        \newif\iffirstfooteritem\firstfooteritemtrue
        \newcommand{\footersep}{~\vline~}%
        
        \ifdefempty{\@obb@fromlandline}{}{%
          \iffirstfooteritem\firstfooteritemfalse\else\footersep\fi
          \Telefon\ \@obb@fromlandline
        }%
        \ifdefempty{\@obb@fromphone}{}{%
          \iffirstfooteritem\firstfooteritemfalse\else\footersep\fi
          \Mobilefone\ \@obb@fromphone
        }%
        \ifdefempty{\@obb@fromemail}{}{%
          \iffirstfooteritem\firstfooteritemfalse\else\footersep\fi
          \Letter\ \@obb@fromemail
        }%
        \ifdefempty{\@obb@fromweb}{}{%
          \iffirstfooteritem\firstfooteritemfalse\else\footersep\fi
          \Mundus\ \@obb@fromweb
        }%
        \ifdefempty{\@obb@fromlinkedin}{}{%
          \iffirstfooteritem\firstfooteritemfalse\else\footersep\fi
          \faLinkedin\ \@obb@fromlinkedin
        }%
      }%
    }%
  \fi

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
      % Breite 72mm
      
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
      
      % Höhe Zone 1 (2mm) - Text nach links verschoben
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

      % --- Fluchtlinie (25mm) - Zeigt die gemeinsame Ausrichtung ---
      % Linie rot und gestrichelt, Text links daneben auf Höhe des Textbeginns (ca. 105mm)
      \draw[red!70, dashed, thin] ($(TL)+(25mm, 0)$) -- ($(TL)+(25mm, -297mm)$);
      \node[anchor=east, font=\fontsize{6}{7}\sffamily, text=red!70, inner sep=2pt] at ($(TL)+(25mm, -108mm)$) {Fluchtlinie (25mm)};

    \end{tikzpicture}
  \fi
}

% --- Betreff manuell setzen ---
\let\@obb@oldopening\opening
\renewcommand{\opening}[1]{%
  \ifdefempty{\@obb@subject}{}{%
    {\bfseries\sffamily\@obb@subject}\par
    \vspace{1em}%
  }%
  \@obb@oldopening{#1}%
}

\endinput
