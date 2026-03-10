\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{onlinebrief24}[2026/03/10 Precision Layout Class with Guides]

% --- Basis: KOMA-Script Briefklasse ---
\LoadClass[fontsize=11pt, parskip=half]{scrlttr2}

% --- Pakete ---
\RequirePackage[ngerman]{babel} % Deutsche Spracheinstellungen (Datum, Trennung)
\RequirePackage{geometry}
\RequirePackage{iftex}
\ifPDFTeX
  \ClassError{onlinebrief24}{This class requires XeLaTeX or LuaLaTeX}{Compile the document with xelatex or lualatex instead of pdflatex because the class uses fontspec.}
\fi
\RequirePackage{fontspec}
\RequirePackage{eso-pic}
\RequirePackage{xcolor}
\RequirePackage{calc}
\RequirePackage{tikz} % Für präzise Zeichnungen im Guides-Modus
\usetikzlibrary{calc, arrows.meta}
\RequirePackage{etoolbox} % Für \ifdefempty

% --- Schriftart: Arial bevorzugt, ansonsten TeX-Gyre-Fallback ---
\IfFontExistsTF{Arial}{%
  \setmainfont{Arial}[Ligatures=TeX]
  \setsansfont{Arial}[Ligatures=TeX]
}{%
  \setmainfont{TeX Gyre Heros}[Ligatures=TeX]
  \setsansfont{TeX Gyre Heros}[Ligatures=TeX]
}

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
\newlength{\@obb@addrwidth}
\newcommand{\@obb@return}{}
\newcommand{\@obb@recipient}{}
\newcommand{\@obb@subject}{}
\newcommand{\@obb@date}{\today}
\newcommand{\@obb@place}{}
\newcommand{\@obb@fromname}{}
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
\newcommand{\@obb@syncplaceanddate}{%
  \setkomavar{date}{\@obb@date}%
  \ifdefempty{\@obb@place}{%
    \setkomavar{place}{}%
  }{%
    \setkomavar{place}{\@obb@place}%
  }%
}
\newcommand{\setdate}[1]{%
  \renewcommand{\@obb@date}{#1}%
  \@obb@syncplaceanddate
}
\newcommand{\setplace}[1]{%
  \renewcommand{\@obb@place}{#1}%
  \@obb@syncplaceanddate
}
\newcommand{\setfromname}[1]{\renewcommand{\@obb@fromname}{#1}} % Legacy
\newcommand{\setfromfirstname}[1]{\renewcommand{\@obb@fromfirstname}{#1}}
\newcommand{\setfromlastname}[1]{\renewcommand{\@obb@fromlastname}{#1}}
\newcommand{\setfromaddress}[1]{\renewcommand{\@obb@fromaddress}{#1}}
\newcommand{\setfromphone}[1]{\renewcommand{\@obb@fromphone}{#1}}
\newcommand{\setfromemail}[1]{\renewcommand{\@obb@fromemail}{#1}}
\newcommand{\setfromweb}[1]{\renewcommand{\@obb@fromweb}{#1}}
\newcommand{\setfromlinkedin}[1]{\renewcommand{\@obb@fromlinkedin}{#1}}
\newcommand{\setfromlandline}[1]{\renewcommand{\@obb@fromlandline}{#1}}
\@obb@syncplaceanddate

% Patch letter environment
\let\@obb@oldletter\letter
\renewcommand{\letter}[1]{%
  \ifstrempty{#1}{}{%
    \ifdefempty{\@obb@recipient}{%
      \renewcommand{\@obb@recipient}{#1}%
    }{%
      \ClassWarningNoLine{onlinebrief24}{Ignoring recipient passed to letter environment because \string\setrecipient\space is already set}%
    }%
  }%
  \@obb@oldletter{}%
}

% --- Optionen ---
\newif\if@guidesmode
\newif\if@modernstyle
\newif\if@footercenter
\DeclareOption{guides}{\@guidesmodetrue}
\DeclareOption{modern}{\@modernstyletrue}
\DeclareOption{footercenter}{\@footercentertrue}
\DeclareOption{basic}{\@modernstylefalse}

% --- Farbschema Optionen (wie moderncv) ---
\def\@obb@colorscheme{grey}% Default: grey
\DeclareOption{blue}{\def\@obb@colorscheme{blue}}
\DeclareOption{orange}{\def\@obb@colorscheme{orange}}
\DeclareOption{green}{\def\@obb@colorscheme{green}}
\DeclareOption{red}{\def\@obb@colorscheme{red}}
\DeclareOption{purple}{\def\@obb@colorscheme{purple}}
\DeclareOption{grey}{\def\@obb@colorscheme{grey}}
\DeclareOption{burgundy}{\def\@obb@colorscheme{burgundy}}
\DeclareOption{black}{\def\@obb@colorscheme{black}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrlttr2}}
\ProcessOptions\relax

% --- Bedingtes Laden für den modernen Stil ---
\if@modernstyle
  \RequirePackage[default, light, semibold]{sourcesanspro}
  \RequirePackage{marvosym}
  
  % --- Farbdefinitionen (moderncv-kompatibel) ---
  \definecolor{color0}{rgb}{0,0,0}% Text (schwarz)
  \definecolor{color2}{rgb}{0.45,0.45,0.45}% Sekundär (dunkelgrau)
  
  % color1 (Akzentfarbe) je nach gewähltem Schema
  \ifdefstring{\@obb@colorscheme}{blue}{\definecolor{color1}{rgb}{0.22,0.45,0.70}}{}%
  \ifdefstring{\@obb@colorscheme}{orange}{\definecolor{color1}{rgb}{0.95,0.55,0.15}}{}%
  \ifdefstring{\@obb@colorscheme}{green}{\definecolor{color1}{rgb}{0.35,0.70,0.30}}{}%
  \ifdefstring{\@obb@colorscheme}{red}{\definecolor{color1}{rgb}{0.95,0.20,0.20}}{}%
  \ifdefstring{\@obb@colorscheme}{purple}{\definecolor{color1}{rgb}{0.50,0.33,0.80}}{}%
  \ifdefstring{\@obb@colorscheme}{grey}{\definecolor{color1}{rgb}{0.55,0.55,0.55}}{}%
  \ifdefstring{\@obb@colorscheme}{burgundy}{\definecolor{color1}{rgb}{0.596,0,0}}{}%
  \ifdefstring{\@obb@colorscheme}{black}{\definecolor{color1}{rgb}{0,0,0}}{}%
\fi

% --- Footer-Hilfsmakros (außerhalb von AddToShipoutPictureBG definiert) ---
\newif\if@obb@firstfooteritem
\newcommand{\@obb@footersep}{~\textbar~}
\newcommand{\@obb@renderheadername}{%
  \ifdefempty{\@obb@fromfirstname}{%
    \ifdefempty{\@obb@fromlastname}{%
      \color{color1}\@obb@fromname%
    }{%
      \color{color1}\@obb@fromlastname%
    }%
  }{%
    \color{color1!50}\@obb@fromfirstname%
    \ifdefempty{\@obb@fromlastname}{}{\ \color{color1}\@obb@fromlastname}%
  }%
}

% --- Layout-Zeichnung ---
\AddToShipoutPictureBG{%
  \setlength{\unitlength}{1mm}%
  
  % --- Inhalt (immer sichtbar) ---
  
      % Zone 1: Ruecksendeanschrift muss komplett oberhalb der Sendungskennzeichnung bleiben.
      % 6pt halten die Textbox innerhalb der 2mm-Zone aus der Onlinebrief24-Spezifikation.
      \put(20, 246.35){%
        \parbox[b][2mm][c]{72mm}{%
          \fontsize{6pt}{6.8pt}\sffamily\selectfont
          \if@guidesmode\color{darkgray}\fi
          \@obb@return
        }%
      }%
      % Unterstrich für Zone 1 - vollstaendig oberhalb der 51mm-Grenze halten
      \settowidth{\@obb@addrwidth}{{\fontsize{6pt}{6.8pt}\sffamily\selectfont\@obb@return}}%
      \ifdim\@obb@addrwidth>72mm\@obb@addrwidth=72mm\fi
      \put(20, 246.08){\rule{\@obb@addrwidth}{0.2pt}}

  % Zone 3: Empfänger (71mm von oben)
  % Linksbündig bei 20mm entsprechend der Referenzvorlage
  \put(20, 205){%
    \parbox[b][20mm][t]{72mm}{%
      \raggedright
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
            \@obb@renderheadername
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
        \global\@obb@firstfooteritemtrue
        %
        \ifdefempty{\@obb@fromlandline}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          \Telefon\ \@obb@fromlandline
        }%
        \ifdefempty{\@obb@fromphone}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          \Mobilefone\ \@obb@fromphone
        }%
        \ifdefempty{\@obb@fromemail}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          \Letter\ \@obb@fromemail
        }%
        \ifdefempty{\@obb@fromweb}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          \Mundus\ \@obb@fromweb
        }%
        \ifdefempty{\@obb@fromlinkedin}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          LinkedIn\ \@obb@fromlinkedin
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
      % Start bei (20mm, -49mm)
      % Breite 72mm
      
      % Zone 1 (Absender): 49mm bis 51mm
      \draw[guide line] ($(TL)+(20mm, -49mm)$) rectangle ++(72mm, -2mm);
      \node[guide text, anchor=west] at ($(TL)+(92mm, -50mm)$) {Zone 1 (Absender)};
      
      % Zone 2 (Sperrzone): 51mm bis 71mm
      \draw[guide line, fill=red!5] ($(TL)+(20mm, -51mm)$) rectangle ++(72mm, -20mm);
      \node[guide text, anchor=west] at ($(TL)+(92mm, -61mm)$) {Zone 2 (Sperrzone/Codes)};
      
      % Zone 3 (Empfänger): 71mm bis 91mm
      \draw[guide line] ($(TL)+(20mm, -71mm)$) rectangle ++(72mm, -20mm);
      \node[guide text, anchor=west] at ($(TL)+(92mm, -81mm)$) {Zone 3 (Empfänger)};
      
      % --- Maßpfeile (Links vom Fenster) ---
      
      % Offset 49mm (Start Fenster)
      \draw[dim line] ($(TL)+(15mm, 0)$) -- ($(TL)+(15mm, -49mm)$) node[dim text, rotate=90] {49mm};
      
      % Höhe Zone 1 (2mm) - Text nach links verschoben
      \draw[dim line] ($(TL)+(15mm, -49mm)$) -- ($(TL)+(15mm, -51mm)$) node[midway, left=1mm, rotate=90, font=\fontsize{5}{6}\sffamily, text=red!70] {2mm};
      
      % Höhe Zone 2 (20mm)
      \draw[dim line] ($(TL)+(15mm, -51mm)$) -- ($(TL)+(15mm, -71mm)$) node[dim text, rotate=90] {20mm};
      
      % Höhe Zone 3 (20mm)
      \draw[dim line] ($(TL)+(15mm, -71mm)$) -- ($(TL)+(15mm, -91mm)$) node[dim text, rotate=90] {20mm};
      
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

      % --- Textfluchtlinie (25mm) für Betreff und Briefkörper ---
      % Linie rot und gestrichelt, Text links daneben auf Höhe des Textbeginns (ca. 105mm)
      \draw[red!70, dashed, thin] ($(TL)+(25mm, 0)$) -- ($(TL)+(25mm, -297mm)$);
      \node[anchor=east, font=\fontsize{6}{7}\sffamily, text=red!70, inner sep=2pt] at ($(TL)+(25mm, -108mm)$) {Textfluchtlinie (25mm)};

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
