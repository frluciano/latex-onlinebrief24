\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{onlinebrief24}[2026/03/22 Precision Layout Class with Guides]

% --- Option declarations (all before ProcessOptions) ---

% Key-value option: lang (accepts any babel language name)
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=obb,prefix=obb@}
\DeclareStringOption[german]{lang}

% Style switches
\newif\if@guidesmode
\newif\if@modernstyle
\newif\if@footercenter
\newif\if@infoblock
\DeclareVoidOption{guides}{\@guidesmodetrue}
\DeclareVoidOption{modern}{\@modernstyletrue}
\DeclareVoidOption{footercenter}{\@footercentertrue}
\DeclareVoidOption{infoblock}{\@infoblocktrue}
\DeclareVoidOption{basic}{\@modernstylefalse}

% Color scheme (moderncv-compatible)
\def\@obb@colorscheme{grey}% Default: grey
\DeclareVoidOption{blue}{\def\@obb@colorscheme{blue}}
\DeclareVoidOption{orange}{\def\@obb@colorscheme{orange}}
\DeclareVoidOption{green}{\def\@obb@colorscheme{green}}
\DeclareVoidOption{red}{\def\@obb@colorscheme{red}}
\DeclareVoidOption{purple}{\def\@obb@colorscheme{purple}}
\DeclareVoidOption{grey}{\def\@obb@colorscheme{grey}}
\DeclareVoidOption{burgundy}{\def\@obb@colorscheme{burgundy}}
\DeclareVoidOption{black}{\def\@obb@colorscheme{black}}

\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{scrlttr2}}
\ProcessKeyvalOptions*

% --- Base: KOMA-Script letter class ---
\LoadClass[fontsize=11pt, parskip=half]{scrlttr2}

% --- Packages ---
% `provide=*` lets babel fall back to locale-INI based language data on leaner
% TeX installations where a legacy `<language>.ldf` file is not installed.
\expandafter\RequirePackage\expandafter[main=\obb@lang,provide=*]{babel}
\RequirePackage{geometry}
\RequirePackage{iftex}
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
\setplength{sigindent}{0pt}
\let\raggedsignature\raggedright

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
\newcommand{\@obb@yourref}{}
\newcommand{\@obb@yourmessage}{}
\newcommand{\@obb@ourref}{}
\newcommand{\@obb@ourmessage}{}
\newcommand{\@obb@contactname}{}
\newcommand{\@obb@contactphone}{}
\newcommand{\@obb@contactfax}{}
\newcommand{\@obb@contactemail}{}
\newcommand{\@obb@defineinfoblocklabel}[3]{%
  \expandafter\def\csname @obb@infoblocklabel@#1@#2\endcsname{#3}%
}
\newlength{\@obb@infoblocklabelwidth}
\newlength{\@obb@infoblockvaluewidth}
\newlength{\@obb@infoblockcolsep}
\newlength{\@obb@infoblockrightedge}
\newlength{\@obb@infoblocktopoffset}
\newcommand{\@obb@usedininfoblocklayout}{%
  % Public DIN-5008 summaries usually place the information block for Form B
  % at roughly 50mm from the top, beginning around 125mm from the left with a
  % maximum width of 75mm. Keep that as the shared class default for both the
  % basic and modern styles so the reference area stays consistent.
  \setlength{\@obb@infoblocklabelwidth}{30mm}%
  \setlength{\@obb@infoblockcolsep}{2mm}%
  \setlength{\@obb@infoblockvaluewidth}{43mm}%
  \setlength{\@obb@infoblockrightedge}{200mm}%
  \setlength{\@obb@infoblocktopoffset}{50mm}%
}
\@obb@usedininfoblocklayout

% --- Public layout API for the information block ---
% These macros let users tune the infoblock position and column widths without
% accessing the internal lengths directly.  Call them in the preamble after
% \documentclass.

% \setinfoblocktopoffset{50mm}
%   Vertical distance from the top of the page to the information block.
%   Default: 50mm (DIN 5008 Form B reference position).
\newcommand{\setinfoblocktopoffset}[1]{\setlength{\@obb@infoblocktopoffset}{#1}}

% \setinfoblockrightedge{200mm}
%   Horizontal distance from the left page edge to the right edge of the block.
%   Default: 200mm (aligns the block near the right text boundary).
\newcommand{\setinfoblockrightedge}[1]{\setlength{\@obb@infoblockrightedge}{#1}}

% \setinfoblockcolwidths{labelwidth}{colsep}{valuewidth}
%   Column widths for the infoblock tabular.
%   Defaults: 30mm label, 2mm separator, 43mm value.
\newcommand{\setinfoblockcolwidths}[3]{%
  \setlength{\@obb@infoblocklabelwidth}{#1}%
  \setlength{\@obb@infoblockcolsep}{#2}%
  \setlength{\@obb@infoblockvaluewidth}{#3}%
}

% Keep localized information-block labels compact enough to fit the shared
% DIN-style geometry without forcing awkward line breaks in longer languages.
\@obb@defineinfoblocklabel{german}{yourref}{Ihr Zeichen}
\@obb@defineinfoblocklabel{german}{yourmessage}{Ihre Nachricht vom}
\@obb@defineinfoblocklabel{german}{ourref}{Unser Zeichen}
\@obb@defineinfoblocklabel{german}{ourmessage}{Unsere Nachricht vom}
\@obb@defineinfoblocklabel{german}{contactname}{Name}
\@obb@defineinfoblocklabel{german}{contactphone}{Telefon}
\@obb@defineinfoblocklabel{german}{contactfax}{Telefax}
\@obb@defineinfoblocklabel{german}{contactemail}{E-Mail}
\@obb@defineinfoblocklabel{ngerman}{yourref}{Ihr Zeichen}
\@obb@defineinfoblocklabel{ngerman}{yourmessage}{Ihre Nachricht vom}
\@obb@defineinfoblocklabel{ngerman}{ourref}{Unser Zeichen}
\@obb@defineinfoblocklabel{ngerman}{ourmessage}{Unsere Nachricht vom}
\@obb@defineinfoblocklabel{ngerman}{contactname}{Name}
\@obb@defineinfoblocklabel{ngerman}{contactphone}{Telefon}
\@obb@defineinfoblocklabel{ngerman}{contactfax}{Telefax}
\@obb@defineinfoblocklabel{ngerman}{contactemail}{E-Mail}
\@obb@defineinfoblocklabel{english}{yourref}{Your reference}
\@obb@defineinfoblocklabel{english}{yourmessage}{Your message of}
\@obb@defineinfoblocklabel{english}{ourref}{Our reference}
\@obb@defineinfoblocklabel{english}{ourmessage}{Our message of}
\@obb@defineinfoblocklabel{english}{contactname}{Name}
\@obb@defineinfoblocklabel{english}{contactphone}{Phone}
\@obb@defineinfoblocklabel{english}{contactfax}{Fax}
\@obb@defineinfoblocklabel{english}{contactemail}{Email}
\@obb@defineinfoblocklabel{french}{yourref}{Vos r\'ef\'erences}
\@obb@defineinfoblocklabel{french}{yourmessage}{Votre message du}
\@obb@defineinfoblocklabel{french}{ourref}{Nos r\'ef\'erences}
\@obb@defineinfoblocklabel{french}{ourmessage}{Notre message du}
\@obb@defineinfoblocklabel{french}{contactname}{Nom}
\@obb@defineinfoblocklabel{french}{contactphone}{T\'el\'ephone}
\@obb@defineinfoblocklabel{french}{contactfax}{Fax}
\@obb@defineinfoblocklabel{french}{contactemail}{E-mail}
\@obb@defineinfoblocklabel{spanish}{yourref}{Su referencia}
\@obb@defineinfoblocklabel{spanish}{yourmessage}{Su mensaje del}
\@obb@defineinfoblocklabel{spanish}{ourref}{Nuestra referencia}
\@obb@defineinfoblocklabel{spanish}{ourmessage}{Nuestro mensaje del}
\@obb@defineinfoblocklabel{spanish}{contactname}{Nombre}
\@obb@defineinfoblocklabel{spanish}{contactphone}{Tel\'efono}
\@obb@defineinfoblocklabel{spanish}{contactfax}{Fax}
\@obb@defineinfoblocklabel{spanish}{contactemail}{E-mail}
\@obb@defineinfoblocklabel{italian}{yourref}{Vostro rif.}
\@obb@defineinfoblocklabel{italian}{yourmessage}{Vostra comunic.\ del}
\@obb@defineinfoblocklabel{italian}{ourref}{Nostro rif.}
\@obb@defineinfoblocklabel{italian}{ourmessage}{Nostra comunic.\ del}
\@obb@defineinfoblocklabel{italian}{contactname}{Nome}
\@obb@defineinfoblocklabel{italian}{contactphone}{Telefono}
\@obb@defineinfoblocklabel{italian}{contactfax}{Fax}
\@obb@defineinfoblocklabel{italian}{contactemail}{E-mail}
\@obb@defineinfoblocklabel{dutch}{yourref}{Uw kenmerk}
\@obb@defineinfoblocklabel{dutch}{yourmessage}{Uw bericht van}
\@obb@defineinfoblocklabel{dutch}{ourref}{Ons kenmerk}
\@obb@defineinfoblocklabel{dutch}{ourmessage}{Ons bericht van}
\@obb@defineinfoblocklabel{dutch}{contactname}{Naam}
\@obb@defineinfoblocklabel{dutch}{contactphone}{Telefoon}
\@obb@defineinfoblocklabel{dutch}{contactfax}{Fax}
\@obb@defineinfoblocklabel{dutch}{contactemail}{E-mail}
\@obb@defineinfoblocklabel{polish}{yourref}{Pa\'nstwa znak}
\@obb@defineinfoblocklabel{polish}{yourmessage}{Pa\'nstwa pismo z dn.}
\@obb@defineinfoblocklabel{polish}{ourref}{Nasz znak}
\@obb@defineinfoblocklabel{polish}{ourmessage}{Nasze pismo z dn.}
\@obb@defineinfoblocklabel{polish}{contactname}{Kontakt}
\@obb@defineinfoblocklabel{polish}{contactphone}{Telefon}
\@obb@defineinfoblocklabel{polish}{contactfax}{Faks}
\@obb@defineinfoblocklabel{polish}{contactemail}{E-mail}
\newcommand{\@obb@getinfoblocklabel}[1]{%
  \ifcsname @obb@infoblocklabel@\languagename @#1\endcsname
    \csname @obb@infoblocklabel@\languagename @#1\endcsname
  \else
    \ifcsname @obb@infoblocklabel@\obb@lang @#1\endcsname
      \csname @obb@infoblocklabel@\obb@lang @#1\endcsname
    \else
      \csname @obb@infoblocklabel@german@#1\endcsname
    \fi
  \fi
}

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
\newcommand{\setyourref}[1]{\renewcommand{\@obb@yourref}{#1}}
\newcommand{\setyourmessage}[1]{\renewcommand{\@obb@yourmessage}{#1}}
\newcommand{\setourref}[1]{\renewcommand{\@obb@ourref}{#1}}
\newcommand{\setourmessage}[1]{\renewcommand{\@obb@ourmessage}{#1}}
\newcommand{\setcontactname}[1]{\renewcommand{\@obb@contactname}{#1}}
\newcommand{\setcontactphone}[1]{\renewcommand{\@obb@contactphone}{#1}}
\newcommand{\setcontactfax}[1]{\renewcommand{\@obb@contactfax}{#1}}
\newcommand{\setcontactemail}[1]{\renewcommand{\@obb@contactemail}{#1}}
% --- Calibrated font dimensions (DIN 5008 / onlinebrief24.de) ---
% The return address uses a reduced font so the full address fits the 72mm
% sender zone on a single line. Both size and leading appear in the validation
% and rendering code; centralising them here keeps the two in sync.
\newcommand{\@obb@returnaddressfontsz}{5.8pt}
\newcommand{\@obb@returnaddresslinesz}{6.4pt}

\newcommand{\@obb@validatereturnaddresswidth}{%
  \begingroup
    \settowidth{\@obb@addrwidth}{{\fontsize{\@obb@returnaddressfontsz}{\@obb@returnaddresslinesz}\sffamily\selectfont\@obb@return}}%
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
  \RequirePackage[default, light, semibold]{sourcesanspro}
  \RequirePackage{fontawesome5}

  % --- Color definitions (moderncv-compatible) ---
  \definecolor{color0}{rgb}{0,0,0}% Text (black)
  \definecolor{color2}{rgb}{0.45,0.45,0.45}% Secondary text (dark gray)

  % color1 (accent color) selected by the chosen scheme.
  % RGB values mirror the moderncv package's built-in palette so that letters
  % compiled alongside a moderncv résumé share a visually consistent accent
  % color without requiring any manual coordination between the two packages.
  \ifdefstring{\@obb@colorscheme}{blue}{\definecolor{color1}{rgb}{0.22,0.45,0.70}}{}%   % moderncv blue
  \ifdefstring{\@obb@colorscheme}{orange}{\definecolor{color1}{rgb}{0.95,0.55,0.15}}{}%  % moderncv orange
  \ifdefstring{\@obb@colorscheme}{green}{\definecolor{color1}{rgb}{0.35,0.70,0.30}}{}%   % moderncv green
  \ifdefstring{\@obb@colorscheme}{red}{\definecolor{color1}{rgb}{0.95,0.20,0.20}}{}%     % moderncv red
  \ifdefstring{\@obb@colorscheme}{purple}{\definecolor{color1}{rgb}{0.50,0.33,0.80}}{}%  % moderncv purple
  \ifdefstring{\@obb@colorscheme}{grey}{\definecolor{color1}{rgb}{0.55,0.55,0.55}}{}%    % moderncv grey
  \ifdefstring{\@obb@colorscheme}{burgundy}{\definecolor{color1}{rgb}{0.596,0,0}}{}%     % moderncv burgundy
  \ifdefstring{\@obb@colorscheme}{black}{\definecolor{color1}{rgb}{0,0,0}}{}%            % moderncv black
\fi

% --- Footer helper macros (defined outside AddToShipoutPictureBG) ---
\newif\if@obb@firstfooteritem
\newcommand{\@obb@footersep}{~\textbar~}

% Extra footer items appended by \addfooteritem (empty by default).
\newcommand{\@obb@extrafooterlist}{}

% \addfooteritem{icon}{text}
%   Appends a custom item to the modern-mode footer. The icon is a fontawesome5
%   command (e.g. \faGithub); it is raised to match the footer baseline. Items
%   are separated by the standard footer separator (\textbar). Must be called in
%   the document preamble, before \begin{document}.
\newcommand{\addfooteritem}[2]{%
  \g@addto@macro\@obb@extrafooterlist{%
    \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
    \@obb@icon{#1}\ #2%
  }%
}
% Normalize fontawesome5 icon metrics to strut height so icons do not
% shift the footer baseline via oversized ascenders or descenders.
\newcommand{\@obb@icon}[1]{\raisebox{0pt}[\ht\strutbox][\dp\strutbox]{#1}}
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
\newcommand{\@obb@infoblocklabelstyle}{%
  \fontsize{8pt}{9.5pt}\sffamily\selectfont
  \if@modernstyle\color{color2}\fi
}
\newcommand{\@obb@infoblockvaluestyle}{%
  \fontsize{8pt}{9.5pt}\sffamily\selectfont
  \if@modernstyle\color{color0}\fi
}
\newcommand{\@obb@renderinfoblockrow}[2]{%
  \ifdefempty{#2}{}{%
    {\@obb@infoblocklabelstyle #1} & {\@obb@infoblockvaluestyle #2}\tabularnewline
  }%
}
% Extra infoblock rows appended by \addinfoblockrow (empty by default).
\newcommand{\@obb@extrainfoblockrows}{}

% \addinfoblockrow{label}{value}
%   Appends a custom row to the DIN-style information block. Both label and
%   value are rendered with the same style as the built-in rows. The row is
%   silently omitted when value is empty so callers do not need to guard it.
%   Must be called in the document preamble, before \begin{document}.
\newcommand{\addinfoblockrow}[2]{%
  \g@addto@macro\@obb@extrainfoblockrows{%
    \@obb@renderinfoblockrow{#1}{#2}%
  }%
}

\newcommand{\@obb@renderinfoblocktable}{%
  \parbox[t]{\dimexpr\@obb@infoblocklabelwidth+\@obb@infoblockcolsep+\@obb@infoblockvaluewidth\relax}{%
    \raggedright
    \renewcommand{\arraystretch}{1.05}%
    \begin{tabular}{@{}p{\@obb@infoblocklabelwidth}@{\hspace{\@obb@infoblockcolsep}}p{\@obb@infoblockvaluewidth}@{}}%
      \@obb@renderinfoblockrow{\@obb@getinfoblocklabel{yourref}}{\@obb@yourref}%
      \@obb@renderinfoblockrow{\@obb@getinfoblocklabel{yourmessage}}{\@obb@yourmessage}%
      \@obb@renderinfoblockrow{\@obb@getinfoblocklabel{ourref}}{\@obb@ourref}%
      \@obb@renderinfoblockrow{\@obb@getinfoblocklabel{ourmessage}}{\@obb@ourmessage}%
      \@obb@renderinfoblockrow{\@obb@getinfoblocklabel{contactname}}{\@obb@contactname}%
      \@obb@renderinfoblockrow{\@obb@getinfoblocklabel{contactphone}}{\@obb@contactphone}%
      \@obb@renderinfoblockrow{\@obb@getinfoblocklabel{contactfax}}{\@obb@contactfax}%
      \@obb@renderinfoblockrow{\@obb@getinfoblocklabel{contactemail}}{\@obb@contactemail}%
      \@obb@extrainfoblockrows
    \end{tabular}%
  }%
}
\newcommand{\@obb@renderinfoblockoverlay}{%
  \if@infoblock
    \ifboolexpr{
      not test {\ifdefempty{\@obb@yourref}} or
      not test {\ifdefempty{\@obb@yourmessage}} or
      not test {\ifdefempty{\@obb@ourref}} or
      not test {\ifdefempty{\@obb@ourmessage}} or
      not test {\ifdefempty{\@obb@contactname}} or
      not test {\ifdefempty{\@obb@contactphone}} or
      not test {\ifdefempty{\@obb@contactfax}} or
      not test {\ifdefempty{\@obb@contactemail}}
    }{%
      % Render the DIN-style information block independently from the text
      % flow so the first-page body start stays stable in both styles.
      \begin{tikzpicture}[remember picture, overlay]
        \node[anchor=north east, inner sep=0pt] at ($(current page.north west)+(\@obb@infoblockrightedge,-\@obb@infoblocktopoffset)$) {%
          \@obb@renderinfoblocktable
        };
      \end{tikzpicture}%
    }{}%
  \fi
}

% --- DIN 5008 window coordinates (picture mode, unitlength=1mm) ---
% In LaTeX picture mode y increases upward from the page bottom. With
% unitlength=1mm these values are millimetres measured from the bottom of an
% A4 sheet (height = 297mm), so y_pic = 297 - y_from_top.
\newcommand{\@obb@picwindowx}{20}       % left edge of address window: 20mm from left
\newcommand{\@obb@piczone1y}{245.00}    % Zone 1 (sender, 2mm high): top at 50mm from top → 297-50=247, bottom at 245mm
\newcommand{\@obb@piczone3y}{204}       % Zone 3 (recipient): calibrated 1mm below the 72mm mark
\newcommand{\@obb@picfoldmarki}{192}    % 1st fold mark: 105mm from top → 297-105=192
\newcommand{\@obb@picfoldmarkii}{92}    % 2nd fold mark: 205mm from top → 297-205=92

% --- Page overlay drawing ---
\newcommand{\@obb@firstpageoverlay}{%
  \setlength{\unitlength}{1mm}%

  % --- Content that is always visible on page 1 ---

      % Zone 1 is tuned separately so the return address stays entirely
      % inside the 2mm sender line without shifting zones 2 and 3.
      \put(\@obb@picwindowx, \@obb@piczone1y){%
        \parbox[b][2mm][c]{72mm}{%
          \fontsize{\@obb@returnaddressfontsz}{\@obb@returnaddresslinesz}\sffamily\selectfont
          \if@guidesmode\color{darkgray}\fi
          \@obb@return
        }%
      }%
      % Keep the underline for zone 1 fully above the 52mm boundary.
      \settowidth{\@obb@addrwidth}{{\fontsize{\@obb@returnaddressfontsz}{\@obb@returnaddresslinesz}\sffamily\selectfont\@obb@return}}%
      \ifdim\@obb@addrwidth>72mm\@obb@addrwidth=72mm\fi
      \put(\@obb@picwindowx, \@obb@piczone1y){\rule{\@obb@addrwidth}{0.2pt}}

  % Zone 3: recipient block, calibrated 1mm lower to match the onlinebrief24.de preview.
  % Left-aligned at 20mm in line with the reference layout.
  \put(\@obb@picwindowx, \@obb@piczone3y){%
    \parbox[b][20mm][t]{72mm}{%
      \raggedright
      \fontsize{11pt}{13pt}\sffamily\selectfont
      \@obb@recipient
    }%
  }%

  % Fold marks (always visible, but subtle)
  \put(5, \@obb@picfoldmarki){\line(1,0){5}}
  \put(5, \@obb@picfoldmarkii){\line(1,0){5}}

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

    % Footer: contact details, kept close to the bottom edge.
    \put(25, 5){%
      \parbox[b][10mm][b]{\textwidth}{%
        \if@footercenter\centering\else\raggedleft\fi
        \footnotesize\sffamily\color{color2}%
        \global\@obb@firstfooteritemtrue
        %
        \ifdefempty{\@obb@fromlandline}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          \@obb@icon{\faPhone}\ \@obb@fromlandline
        }%
        \ifdefempty{\@obb@fromphone}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          \@obb@icon{\faMobile}\ \@obb@fromphone
        }%
        \ifdefempty{\@obb@fromemail}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          \@obb@icon{\faEnvelope}\ \@obb@fromemail
        }%
        \ifdefempty{\@obb@fromweb}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          \@obb@icon{\faGlobe}\ \@obb@fromweb
        }%
        \ifdefempty{\@obb@fromlinkedin}{}{%
          \if@obb@firstfooteritem\global\@obb@firstfooteritemfalse\else\@obb@footersep\fi
          \@obb@icon{\faLinkedin}\ \@obb@fromlinkedin
        }%
        \@obb@extrafooterlist
      }%
    }%
  \fi

  \@obb@renderinfoblockoverlay

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
      % Calibrated 1mm lower to match the onlinebrief24.de preview.
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
%
% \opening reimplements the scrlttr2 version so the document body starts at
% the precise vertical offset required by DIN 5008 Form B rather than at
% KOMA's default placement.
%
% Internal KOMA macros used here and why they are safe to call:
%
%   \@PapersizeWarning   — issues a warning if the PDF paper size does not
%                          match the document class paper option.  Harmless
%                          when the paper size is correct; kept for safety.
%
%   \@foldmarks          — renders the KOMA fold-mark ticks.  Disabled via
%                          KOMAoptions{foldmarks=false} above, so this is a
%                          no-op.  Called so future KOMA hooks still fire.
%
%   \@firstheadfootfield — renders the KOMA letterhead and footer.  Disabled
%                          via KOMAoptions{firsthead=false,firstfoot=false},
%                          no-op.
%
%   \@addrfield          — renders the KOMA address field.  Disabled via
%                          KOMAoptions{addrfield=false}, no-op.
%
%   \@locfield           — renders the KOMA location field.  Not configured;
%                          no-op.
%
% By disabling these components above but still calling them here, any hooks
% or assertions KOMA adds in future versions will continue to be exercised.
%
% Risk: a KOMA update that changes the signature of these macros will break
% \opening.  Mitigation: verify.sh regression tests cover this on every CI run.
%
% The \setparsizes line resets the paragraph shape inside the salutation (#1)
% so no indentation or extra space from the body settings leaks into the
% opening line.  \par@updaterelative flushes the change before the paragraph.
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
