\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{onlinebrief24}[2026/03/10 v1.0.0 Precision Layout Class with Guides]

% --- Option declarations (all before ProcessOptions) ---

% Key-value option: lang (accepts any babel language name)
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=obb,prefix=obb@}
\DeclareStringOption[ngerman]{lang}

% Style switches
\newif\if@guidesmode
\newif\if@modernstyle
\newif\if@footercenter
\DeclareOption{guides}{\@guidesmodetrue}
\DeclareOption{modern}{\@modernstyletrue}
\DeclareOption{footercenter}{\@footercentertrue}
\DeclareOption{basic}{\@modernstylefalse}

% Color scheme (moderncv-compatible)
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
\ProcessKeyvalOptions{obb}
\ProcessOptions\relax

% --- Base: KOMA-Script letter class ---
\LoadClass[fontsize=11pt, parskip=half]{scrlttr2}

% --- Packages ---
\expandafter\RequirePackage\expandafter[\obb@lang]{babel}
\RequirePackage{geometry}
\RequirePackage{iftex}
\RequirePackage{eso-pic}
\RequirePackage{xcolor}
\RequirePackage{calc}
\RequirePackage{tikz} % Used for precise drawing in guides mode
\usetikzlibrary{calc, arrows.meta}
\RequirePackage{etoolbox} % Used for \ifdefempty

% --- Engine-aware font setup ---
\ifPDFTeX
  \RequirePackage[T1]{fontenc}
  \RequirePackage{tgheros}% TeX Gyre Heros (Helvetica/Arial clone)
  \renewcommand{\familydefault}{\sfdefault}
\else
  \RequirePackage{fontspec}
  \IfFontExistsTF{Arial}{%
    \setmainfont{Arial}[Ligatures=TeX]
    \setsansfont{Arial}[Ligatures=TeX]
  }{%
    \setmainfont{TeX Gyre Heros}[Ligatures=TeX]
    \setsansfont{TeX Gyre Heros}[Ligatures=TeX]
  }
\fi

% --- Disable KOMA-Script built-ins we replace ourselves ---
\KOMAoptions{
  addrfield=false,
  firsthead=false,
  firstfoot=false,
  foldmarks=false
}

% --- Page layout ---
\newcommand{\@obb@openingvskip}{85mm}
\geometry{
  paper=a4paper,
  top=25mm,
  bottom=25mm,
  left=25mm,
  right=20mm,
  footskip=10mm
}

% --- Stored document data ---
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
\newcommand{\@obb@validatereturnaddresswidth}{%
  \begingroup
    \settowidth{\@obb@addrwidth}{{\fontsize{5.8pt}{6.4pt}\sffamily\selectfont\@obb@return}}%
    \ifdim\@obb@addrwidth>72mm
      \endgroup
      \ClassError{onlinebrief24}{Return address too long}{Shorten the return address so it fits on a single line within the 72mm sender zone.}%
    \else
      \endgroup
    \fi
}
\newcommand{\@obb@validateletterfields}{%
  \ifdefempty{\@obb@return}{%
    \ClassError{onlinebrief24}{Missing return address}{Set the return address with \string\setreturnaddress\space before \string\begin{document}. The return address is mandatory for the address window.}%
  }{%
    \@obb@validatereturnaddresswidth
  }%
  \ifdefempty{\@obb@recipient}{%
    \ClassError{onlinebrief24}{Missing recipient}{Set the recipient with \string\setrecipient\space or pass it to \string\begin{letter}{...}. The recipient address is mandatory for the address window.}%
  }{}%
}
\@obb@syncplaceanddate

% Patch the letter environment
\let\@obb@oldletter\letter
\renewcommand{\letter}[1]{%
  \ifstrempty{#1}{}{%
    \ifdefempty{\@obb@recipient}{%
      \renewcommand{\@obb@recipient}{#1}%
    }{%
      \ClassWarningNoLine{onlinebrief24}{Ignoring recipient passed to letter environment because \string\setrecipient\space is already set}%
    }%
  }%
  \@obb@validateletterfields
  \@obb@oldletter{}%
}

% --- Conditional loading for the modern style ---
\if@modernstyle
  \ifPDFTeX
    \RequirePackage[default, light, semibold]{sourcesanspro}
  \else
    \RequirePackage[default, light, semibold]{sourcesanspro}
  \fi
  \RequirePackage{marvosym}

  % --- Color definitions (moderncv-compatible) ---
  \definecolor{color0}{rgb}{0,0,0}% Text (black)
  \definecolor{color2}{rgb}{0.45,0.45,0.45}% Secondary text (dark gray)

  % color1 (accent color) selected by the chosen scheme
  \ifdefstring{\@obb@colorscheme}{blue}{\definecolor{color1}{rgb}{0.22,0.45,0.70}}{}%
  \ifdefstring{\@obb@colorscheme}{orange}{\definecolor{color1}{rgb}{0.95,0.55,0.15}}{}%
  \ifdefstring{\@obb@colorscheme}{green}{\definecolor{color1}{rgb}{0.35,0.70,0.30}}{}%
  \ifdefstring{\@obb@colorscheme}{red}{\definecolor{color1}{rgb}{0.95,0.20,0.20}}{}%
  \ifdefstring{\@obb@colorscheme}{purple}{\definecolor{color1}{rgb}{0.50,0.33,0.80}}{}%
  \ifdefstring{\@obb@colorscheme}{grey}{\definecolor{color1}{rgb}{0.55,0.55,0.55}}{}%
  \ifdefstring{\@obb@colorscheme}{burgundy}{\definecolor{color1}{rgb}{0.596,0,0}}{}%
  \ifdefstring{\@obb@colorscheme}{black}{\definecolor{color1}{rgb}{0,0,0}}{}%
\fi

% --- Footer helper macros (defined outside AddToShipoutPictureBG) ---
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
\newcommand{\@obb@renderdateline}{%
  \ifdefempty{\@obb@place}{%
    \@obb@date%
  }{%
    \@obb@place, \@obb@date%
  }%
}
\newcommand{\@obb@renderopeningheader}{%
  \noindent
  \ifdefempty{\@obb@subject}{%
    \hfill\parbox[t]{0.36\textwidth}{\raggedleft\@obb@renderdateline}%
  }{%
    \parbox[t]{0.60\textwidth}{\bfseries\sffamily\@obb@subject}%
    \hfill
    \parbox[t]{0.36\textwidth}{\raggedleft\@obb@renderdateline}%
  }%
  \par
}

% --- Page overlay drawing ---
\newcommand{\@obb@firstpageoverlay}{%
  \setlength{\unitlength}{1mm}%

  % --- Content that is always visible on page 1 ---

      % Zone 1 is tuned separately so the return address stays entirely
      % inside the 2mm sender line without shifting zones 2 and 3.
      \put(20, 245.00){%
        \parbox[b][2mm][c]{72mm}{%
          \fontsize{5.8pt}{6.4pt}\sffamily\selectfont
          \if@guidesmode\color{darkgray}\fi
          \@obb@return
        }%
      }%
      % Keep the underline for zone 1 fully above the 52mm boundary.
      \settowidth{\@obb@addrwidth}{{\fontsize{5.8pt}{6.4pt}\sffamily\selectfont\@obb@return}}%
      \ifdim\@obb@addrwidth>72mm\@obb@addrwidth=72mm\fi
      \put(20, 245.00){\rule{\@obb@addrwidth}{0.2pt}}

  % Zone 3: recipient block, calibrated 1mm lower to match the Onlinebrief24 preview.
  % Left-aligned at 20mm in line with the reference layout.
  \put(20, 204){%
    \parbox[b][20mm][t]{72mm}{%
      \raggedright
      \fontsize{11pt}{13pt}\sffamily\selectfont
      \@obb@recipient
    }%
  }%

  % Fold marks (always visible, but subtle)
  \put(5, 192){\line(1,0){5}}
  \put(5, 92){\line(1,0){5}}

  % --- Modern style (header and footer) ---
  \if@modernstyle
    % Header: sender name
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

    % Footer: contact details
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

  % --- Guides mode (technical overlay) ---
  \if@guidesmode
    \begin{tikzpicture}[remember picture, overlay]
      % Define a top-left origin to make coordinates easier to reason about
      \coordinate (TL) at (current page.north west);

      % Styles
      \tikzset{
        guide line/.style={draw=blue!50, thin},
        guide text/.style={font=\fontsize{7}{8}\sffamily, text=blue!70, inner sep=1pt},
        guide fill/.style={fill opacity=0.42, draw opacity=1},
        dim line/.style={draw=red!70, thin, |<->|},
        dim text/.style={midway, fill=white, font=\fontsize{6}{7}\sffamily, text=red!70, inner sep=1pt}
      }

      % --- Window frame ---
      % Calibrated 1mm lower to match the Onlinebrief24 preview.
      % Start at (20mm, -50mm)
      % Width 72mm

      % Zone 1 (sender): 50mm to 52mm
      \draw[guide line, guide fill, fill=blue!18] ($(TL)+(20mm, -50mm)$) rectangle ++(72mm, -2mm);
      \node[guide text, anchor=west] at ($(TL)+(92mm, -51mm)$) {Zone 1 (Absender)};

      % Zone 2 (reserved/code area): 52mm to 72mm
      \draw[guide line, guide fill, fill=red!22] ($(TL)+(20mm, -52mm)$) rectangle ++(72mm, -20mm);
      \node[guide text, anchor=west] at ($(TL)+(92mm, -62mm)$) {Zone 2 (Sperrzone/Codes)};

      % Zone 3 (recipient): 72mm to 92mm
      \draw[guide line, guide fill, fill=green!22] ($(TL)+(20mm, -72mm)$) rectangle ++(72mm, -20mm);
      \node[guide text, anchor=west] at ($(TL)+(92mm, -82mm)$) {Zone 3 (Empfänger)};

      % --- Dimension markers (left of the window) ---

      % 50mm offset (window start)
      \draw[dim line] ($(TL)+(15mm, 0)$) -- ($(TL)+(15mm, -50mm)$) node[dim text, rotate=90] {50mm};

      % Height of zone 1 (2mm) with label shifted left
      \draw[dim line] ($(TL)+(15mm, -50mm)$) -- ($(TL)+(15mm, -52mm)$) node[midway, left=1mm, rotate=90, font=\fontsize{5}{6}\sffamily, text=red!70] {2mm};

      % Height of zone 2 (20mm)
      \draw[dim line] ($(TL)+(15mm, -52mm)$) -- ($(TL)+(15mm, -72mm)$) node[dim text, rotate=90] {20mm};

      % Height of zone 3 (20mm)
      \draw[dim line] ($(TL)+(15mm, -72mm)$) -- ($(TL)+(15mm, -92mm)$) node[dim text, rotate=90] {20mm};

      % Horizontal offset (20mm)
      \draw[dim line] ($(TL)+(0, -40mm)$) -- ($(TL)+(20mm, -40mm)$) node[dim text] {20mm};

      % Window width (72mm)
      \draw[dim line] ($(TL)+(20mm, -40mm)$) -- ($(TL)+(92mm, -40mm)$) node[dim text] {72mm};

      % --- Fold mark annotations (text at the end of the line) ---
      \draw[red!70, thin, <-] ($(TL)+(6mm, -105mm)$) -- ($(TL)+(15mm, -105mm)$) node[anchor=west, rotate=90, font=\fontsize{6}{7}\sffamily, text=red!70, inner sep=1pt] {1. Falz (105mm)};

      \draw[red!70, thin, <-] ($(TL)+(6mm, -205mm)$) -- ($(TL)+(15mm, -205mm)$) node[anchor=west, rotate=90, font=\fontsize{6}{7}\sffamily, text=red!70, inner sep=1pt] {2. Falz (205mm)};

      % --- Text start line (indicated only, not full width) ---
      \draw[guide line, dashed] ($(TL)+(20mm, -110mm)$) -- ($(TL)+(100mm, -110mm)$);
      \node[guide text, anchor=south west] at ($(TL)+(25mm, -110mm)$) {Textbeginn (110mm)};

      % --- Text alignment line (25mm) for subject and body text ---
      % Start it only below the text area so the window remains unobstructed.
      \draw[red!70, dashed, thin] ($(TL)+(25mm, -110mm)$) -- ($(TL)+(25mm, -297mm)$);
      \node[anchor=east, font=\fontsize{6}{7}\sffamily, text=red!70, inner sep=2pt] at ($(TL)+(25mm, -108mm)$) {Textfluchtlinie (25mm)};

    \end{tikzpicture}
  \fi
}
\AtBeginDocument{%
  \AddToShipoutPictureBG*{\@obb@firstpageoverlay}%
}

% --- Render the subject line manually ---
\renewcommand{\opening}[1]{%
  \@PapersizeWarning
  \thispagestyle{empty}%
  \noindent
  \@foldmarks\@firstheadfootfield
  \@addrfield\@locfield
  \vspace*{\@obb@openingvskip}%
  \@obb@renderopeningheader
  \vspace{\baselineskip}%
  {\setparsizes{\z@}{\z@}{\z@ plus 1fil}\par@updaterelative#1\par}%
  {\setlength{\@tempdima}{\baselineskip}%
    \addtolength{\@tempdima}{-\parskip}%
    \ifdim \@tempdima>\z@\vskip\@tempdima\fi}%
  \@afterindentfalse\@afterheading
}

\endinput
