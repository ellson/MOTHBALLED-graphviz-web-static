;;; Debugging info for self: Saved through ges-version 1.5dev
;;; ;;; From: P Pareit <pieter.pareit@planetinternet.be>
;;; ;;; Subject: graphviz-dot-mode.el v0.2 (dot-mode.el)
;;; ;;; Newsgroups: gnu.emacs.sources
;;; ;;; Date: Mon, 11 Nov 2002 18:53:59 +0100
;;; ;;; Organization: -= Skynet Usenet Service =-

;;; Hey,

;;; This is dot-mode renamed to graphviz-dot-mode. There are also
;;; 2 new features, see "Commentary" in the source.

;;; Pieter

;;; ; Start to copy at the next line or get it at http::/users.skynet.be/ppareit/graphviz-dot-mode.el .
;;; graphviz-dot-mode.el --- Mode for the dot-language used by graphviz (att).

;; Copyright (C) 2002 Pieter E.J. Pareit <pieter.pareit@planetinternet.be>

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.

;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA

;; Author: Pieter E.J. Pareit <pieter.pareit@planetinternet.be>
;; Maintainer: Pieter E.J. Pareit <pieter.pareit@planetinternet.be>
;; Created: 28 Oct 2002
;; Version: 0.2
;; Keywords: mode dot dot-language dotlanguage graphviz graphs att

;;; Commentary:
;; Use this mode for editing files in the dot-language (www.graphviz.org and
;; http://www.research.att.com/sw/tools/graphviz/).
;; To use graphviz-dot-mode, add (load-file "PATH_TO_FILE/graphviz-dot-mode.el") to your .emacs.
;; The graphviz-dot-mode will do font locking, indentation and handles insertion of
;; comments.
;; Font locking is automatic, indentation uses the same commands as other
;; modes, tab, M-j and C-M-q.  Insertion of comments uses the same commands as other
;; modes, M-; .
;; You can compile a file using M-x compile or C-c c, after that M-x next-error will
;; also work.
;; There is support for viewing an generated image with C-c p.

;;; History:
;; Version 0.2 added features
;; 11/11/2002: added preview support.
;; 10/11/2002: indent a graph or subgraph at once with C-M-q.
;; 08/11/2002: relaxed rules for indentation, the may now be extra chars
;;             after beginning of graph (comment's for example).
;; Version 0.1.2 bug fixes and naming issues
;; 06/11/2002: renamed dot-font-lock-defaults to dot-font-lock-keywords.
;;             added some documentation to dot-colors.
;;             provided a much better way to handle my max-specpdl-size
;;             problem.
;;             added an extra autoload cookie (hope this helps, as I don't
;;             yet use autoload myself)
;; Version 0.1.1 bug fixes
;; 06/11/2002: added an missing attribute, for font-locking to work.
;;             fixed the regex generating, so that it only recognizes
;;             whole words
;; 05/11/2002: there can now be extra white space chars after an '{'.
;; 04/11/2002: Why I use max-specpdl-size is now documented, and old value
;;             gets restored.
;; Version 0.1 initial release
;; 02/11/2002: implemented parser for *compilation* of a .dot file.
;; 01/11/2002: implemented compilation of an .dot file.
;; 31/10/2002: added syntax-table to the mode.
;; 30/10/2002: implemented indentation code.
;; 29/10/2002: implemented all of font-lock.
;; 28/10/2002: derived graphviz-dot-mode from fundamental-mode, started implementing
;;             font-lock.

;;; Code:

;;; Key map
(defvar graphviz-dot-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-\M-q" 'graphviz-dot-indent-graph)
    (define-key map "\C-cp" 'graphviz-dot-preview)
    (define-key map "\C-cc" 'compile)
    map)
  "Keymap for `graphviz-dot-mode'.")
; (makunbound 'graphviz-dot-mode-map)

;;; Syntax table
(defvar graphviz-dot-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    st)
  "Syntax table for `graphviz-dot-mode'.")

;;; Font-locking:
(defvar graphviz-dot-colors-list
  '(aliceblue antiquewhite antiquewhite1 antiquewhite2
	      antiquewhite3 antiquewhite4 aquamarine aquamarine1
	      aquamarine2 aquamarine3 aquamarine4 azure azure1
	      azure2 azure3 azure4 beige bisque bisque1 bisque2
	      bisque3 bisque4 black blanchedalmond blue blue1
	      blue2 blue3 blue4 blueviolet brown brown1 brown2
	      brown3 brown4 burlywood burlywood1 burlywood2
	      burlywood3 burlywood4 cadetblue cadetblue1
	      cadetblue2 cadetblue3 cadetblue4 chartreuse
	      chartreuse1 chartreuse2 chartreuse3 chartreuse4
	      chocolate chocolate1 chocolate2 chocolate3 chocolate4
	      coral coral1 coral2 coral3 coral4 cornflowerblue
	      cornsilk cornsilk1 cornsilk2 cornsilk3 cornsilk4
	      crimson cyan cyan1 cyan2 cyan3 cyan4 darkgoldenrod
	      darkgoldenrod1 darkgoldenrod2 darkgoldenrod3
	      darkgoldenrod4 darkgreen darkkhaki darkolivegreen
	      darkolivegreen1 darkolivegreen2 darkolivegreen3
	      darkolivegreen4 darkorange darkorange1 darkorange2
	      darkorange3 darkorange4 darkorchid darkorchid1
	      darkorchid2 darkorchid3 darkorchid4 darksalmon
	      darkseagreen darkseagreen1 darkseagreen2
	      darkseagreen3 darkseagreen4 darkslateblue
	      darkslategray darkslategray1 darkslategray2
	      darkslategray3  darkslategray4 darkslategrey
	      darkturquoise darkviolet deeppink deeppink1
	      deeppink2 deeppink3 deeppink4 deepskyblue
	      deepskyblue1 deepskyblue2 deepskyblue3 deepskyblue4
	      dimgray dimgrey  dodgerblue dodgerblue1 dodgerblue2
	      dodgerblue3  dodgerblue4 firebrick firebrick1
	      firebrick2 firebrick3 firebrick4 floralwhite
	      forestgreen gainsboro ghostwhite gold gold1 gold2
	      gold3 gold4 goldenrod goldenrod1 goldenrod2
	      goldenrod3 goldenrod4 gray gray0 gray1 gray10 gray100
	      gray11 gray12 gray13 gray14 gray15 gray16 gray17
	      gray18 gray19 gray2 gray20 gray21 gray22 gray23
	      gray24 gray25 gray26 gray27 gray28 gray29 gray3
	      gray30 gray31 gray32 gray33 gray34 gray35 gray36
	      gray37 gray38 gray39 gray4 gray40 gray41 gray42
	      gray43 gray44 gray45 gray46 gray47 gray48 gray49
	      gray5 gray50 gray51 gray52 gray53 gray54 gray55
	      gray56 gray57 gray58 gray59 gray6 gray60 gray61
	      gray62 gray63 gray64 gray65 gray66 gray67 gray68
	      gray69 gray7 gray70 gray71 gray72 gray73 gray74
	      gray75 gray76 gray77 gray78 gray79 gray8 gray80
	      gray81 gray82 gray83 gray84 gray85 gray86 gray87
	      gray88 gray89 gray9 gray90 gray91 gray92 gray93
	      gray94 gray95 gray96 gray97 gray98 gray99 green
	      green1 green2 green3 green4 greenyellow grey grey0
	      grey1 grey10 grey100 grey11 grey12 grey13 grey14
	      grey15 grey16 grey17 grey18 grey19 grey2 grey20
	      grey21 grey22 grey23 grey24 grey25 grey26 grey27
	      grey28 grey29 grey3 grey30 grey31 grey32 grey33
	      grey34 grey35 grey36 grey37 grey38 grey39 grey4
	      grey40 grey41 grey42 grey43 grey44 grey45 grey46
	      grey47 grey48 grey49 grey5 grey50 grey51 grey52
	      grey53 grey54 grey55 grey56 grey57 grey58 grey59
	      grey6 grey60 grey61 grey62 grey63 grey64 grey65
	      grey66 grey67 grey68 grey69 grey7 grey70 grey71
	      grey72 grey73 grey74 grey75 grey76 grey77 grey78
	      grey79 grey8 grey80 grey81 grey82 grey83 grey84
	      grey85 grey86 grey87 grey88 grey89 grey9 grey90
	      grey91 grey92 grey93 grey94 grey95 grey96 grey97
	      grey98 grey99 honeydew honeydew1 honeydew2 honeydew3
	      honeydew4 hotpink hotpink1 hotpink2 hotpink3 hotpink4
	      indianred indianred1 indianred2 indianred3 indianred4
	      indigo ivory ivory1 ivory2 ivory3 ivory4 khaki khaki1
	      khaki2 khaki3 khaki4 lavender lavenderblush
	      lavenderblush1 lavenderblush2 lavenderblush3
	      lavenderblush4 lawngreen lemonchiffon lemonchiffon1
	      lemonchiffon2 lemonchiffon3 lemonchiffon4 lightblue
	      lightblue1 lightblue2 lightblue3 lightblue4
	      lightcoral lightcyan lightcyan1 lightcyan2 lightcyan3
	      lightcyan4 lightgoldenrod lightgoldenrod1
	      lightgoldenrod2 lightgoldenrod3 lightgoldenrod4
	      lightgoldenrodyellow lightgray lightgrey lightpink
	      lightpink1 lightpink2 lightpink3 lightpink4
	      lightsalmon lightsalmon1 lightsalmon2 lightsalmon3
	      lightsalmon4 lightseagreen lightskyblue lightskyblue1
	      lightskyblue2 lightskyblue3 lightskyblue4
	      lightslateblue lightslategray lightslategrey
	      lightsteelblue lightsteelblue1 lightsteelblue2
	      lightsteelblue3 lightsteelblue4 lightyellow
	      lightyellow1 lightyellow2 lightyellow3 lightyellow4
	      limegreen linen magenta magenta1 magenta2 magenta3
	      magenta4 maroon maroon1 maroon2 maroon3 maroon4
	      mediumaquamarine mediumblue  mediumorchid
	      mediumorchid1 mediumorchid2 mediumorchid3
	      mediumorchid4 mediumpurple mediumpurple1
	      mediumpurple2 mediumpurple3 mediumpurple4
	      mediumseagreen mediumslateblue mediumspringgreen
	      mediumturquoise mediumvioletred midnightblue
	      mintcream mistyrose mistyrose1 mistyrose2 mistyrose3
	      mistyrose4 moccasin navajowhite navajowhite1
	      navajowhite2 navajowhite3 navajowhite4 navy navyblue
	      oldlace olivedrab olivedrap olivedrab1 olivedrab2
	      olivedrap3 oragne palegoldenrod palegreen palegreen1
	      palegreen2 palegreen3 palegreen4 paleturquoise
	      paleturquoise1 paleturquoise2 paleturquoise3
	      paleturquoise4 palevioletred palevioletred1
	      palevioletred2 palevioletred3 palevioletred4
	      papayawhip peachpuff peachpuff1 peachpuff2
	      peachpuff3 peachpuff4 peru pink pink1 pink2 pink3
	      pink4 plum plum1 plum2 plum3 plum4 powderblue
	      purple purple1 purple2 purple3 purple4 red red1 red2
	      red3 red4 rosybrown rosybrown1 rosybrown2 rosybrown3
	      rosybrown4 royalblue royalblue1 royalblue2 royalblue3
	      royalblue4 saddlebrown salmon salmon1 salmon2 salmon3
	      salmon4 sandybrown seagreen seagreen1 seagreen2
	      seagreen3 seagreen4 seashell seashell1 seashell2
	      seashell3 seashell4 sienna sienna1 sienna2 sienna3
	      sienna4 skyblue skyblue1 skyblue2 skyblue3 skyblue4
	      slateblue slateblue1 slateblue2 slateblue3 slateblue4
	      slategray slategray1 slategray2 slategray3 slategray4
	      slategrey snow snow1 snow2 snow3 snow4 springgreen
	      springgreen1 springgreen2 springgreen3 springgreen4
	      steelblue steelblue1 steelblue2 steelblue3 steelblue4
	      tan tan1 tan2 tan3 tan4 thistle thistle1 thistle2
	      thistle3 thistle4 tomato tomato1 tomato2 tomato3
	      tomato4 transparent turquoise turquoise1 turquoise2
	      turquoise3 turquoise4 violet violetred violetred1
	      violetred2 violetred3 violetred4 wheat wheat1 wheat2
	      wheat3 wheat4 white whitesmoke yellow yellow1 yellow2
	      yellow3 yellow4 yellowgreen)
  "Possible color constants in the dot language.
The list of constant is available at http://www.research.att.com/~erg/graphviz\
/info/colors.html")


(defvar graphviz-dot-font-lock-color-constant-face font-lock-constant-face
  "Face name to use for colors as a constant.
Defaults to `font-lock-constant-face' but you could set it to something else.")

(defvar graphviz-dot-font-lock-keywords
  `(("\\(:?di\\|sub\\)?graph \\(\\sw+\\)"
     (2 font-lock-function-name-face))
    (,(regexp-opt '("true" "false"
		    "normal" "inv" "dot" "invdot"
		    "odot" "invodot" "none" "tee"
		    "empty"
		    "invempty" "diamond"
		    "odiamond" "box"
		    "obox" "open" "crow"
		    "halfopen"
		    "local" "global" "none"
		    "forward" "back" "both" "none"
		    "BL" "BR" "TL" "TR" "RB" "RT"
		    "LB" "LT"
		    ":n" ":ne" ":e" ":se" ":s"
		    ":sw" ":w" ":nw"
		    "same" "min" "source" "max"
		    "sink"
		    "LR"
		    "box" "polygon" "ellipse"
		    "circle" "point"
		    "egg" "triangle" "plaintext"
		    "diamond"
		    "trapezium" "parallelogram"
		    "house" "hexagon"
		    "octagon" "doublecircle"
		    "doubleoctagon"
		    "tripleoctagon" "invtriangle"
		    "invtrapezium"
		    "invhouse" "Mdiamond"
		    "Msquare" "Mcircle"
		    "record" "Mrecord"
		    "dashed" "dotted" "solid"
		    "invis" "bold"
		    "filled" "diagonals"
		    "rounded" ) 'words)
     . font-lock-constant-face)
    ;; to build the font-locking for the colors,
    ;; we need more room for max-specpdl-size,
    ;; after that we take the list of symbols,
    ;; convert them to a list of strings, and make
    ;; an optimized regexp from them
    (,(let ((max-specpdl-size (max max-specpdl-size 1200)))
	(regexp-opt
	 (mapcar 'symbol-name graphviz-dot-colors-list)))
     . graphviz-dot-font-lock-color-constant-face)
    (,(regexp-opt '("graph" "digraph" "subgraph"
		    "node" "edge" "strict")
		  'words)
     . font-lock-keyword-face)
    (,(concat
       (regexp-opt '("Damping" "Epsilon" "URL"
		     "arrowhead" "arrowsize"
		     "arrowtail" "bb" "bgcolor"
		     "bottomlabel" "center"
		     "clusterrank" "color"
		     "comment" "compound"
		     "concentrate" "constraint"
		     "decorate" "dim" "dir"
		     "distortion" "fillcolor"
		     "fixedsize" "fontcolor"
		     "fontname" "fontpath"
		     "fontsize" "group" "headURL"
		     "headlabel" "headport"
		     "height" "label" "labelangle"
		     "labeldistance" "labelfloat"
		     "labelfontcolor"
		     "labelfontname" "labelfontsize"
		     "labeljust" "labelloc" "layer"
		     "layers" "len" "lhead" "lp"
		     "ltail" "margin" "maxiter"
		     "mclimit" "minlen" "model"
		     "nodesep" "normalize" "nslimit"
		     "nslimit1" "ordering"
		     "orientation" "overlap" "pack"
		     "page" "pagedir" "pencolor"
		     "peripheries" "pin" "pos"
		     "quantum" "rank" "rankdir"
		     "ranksep" "ratio" "rects"
		     "regular" "remincross"
		     "rotate" "samehead" "sametail"
		     "samplepoint" "searchsize"
		     "sep" "shape" "shapefile"
		     "showboxes" "sides" "size"
		     "skew" "splines" "start"
		     "style" "stylesheet" "tailURL"
		     "taillabel" "tailport"
		     "toplabel" "vertices"
		     "voro_margin" "weight" "z")
		   'words)
       "[ \\t\\n]*=")
     (1 font-lock-builtin-face)))
  "Keyword highlighting specification for `graphviz-dot-mode'.")

;;;###autoload
(define-derived-mode graphviz-dot-mode fundamental-mode "dot"
  "Major mode for the dot language.
\\{graphviz-dot-mode-map}"
  (set (make-local-variable 'comment-start) "//")
  (set (make-local-variable 'comment-start-skip) "/\\*+ *\\|//+ *")
  (set (make-local-variable 'font-lock-defaults) '(graphviz-dot-font-lock-keywords))
  (set (make-local-variable 'indent-line-function) 'graphviz-dot-indent-line)
  (set (make-local-variable 'compile-command) (concat "dot -Tpng "
						      buffer-file-name
						      " > "
						      (file-name-sans-extension
						       buffer-file-name)
						      ".png"))
  (set (make-local-variable 'compilation-parse-errors-function)
       'graphviz-dot-compilation-parse-errors)
  )

;;;; Compilation

;; note on graphviz-dot-compilation-parse-errors:
;;  It would nicer if we could just use compilation-error-regexp-alist
;;  to do that, 3 options:
;;   - still write dot-compilation-parse-errors, don't build
;;     a return list, but modify the *compilation* buffer
;;     in a way compilation-error-regexp-alist recognizes the
;;     format.
;;     to do that, I should globally change compilation-parse-function
;;     to this function, and call the old value of comp..-parse-fun..
;;     to provide the return value.
;;     two drawbacks are that, every compilation would be run through
;;     this function (performance) and that in autoload there would
;;     be a chance that this function would not yet be known.
;;   - let the compilation run through a filter that would
;;     modify the output of dot or neato:
;;     dot -Tpng input.dot | filter
;;     drawback: ugly, extra work for user, extra decency ...
;;               no-option
;;   - modify dot and neato !!!
(defun graphviz-dot-compilation-parse-errors (limit-search find-at-least)
  "Parse the current buffer for dot errors.
See variable `compilation-parse-errors-functions' for interface."
  (interactive)
  (save-excursion
    (set-buffer "*compilation*")
    (goto-char (point-min))
    (setq compilation-error-list nil)
    (let (buffer-of-error)
      (while (not (eobp))
	(cond
	 ((looking-at "^dot\\( -[^ ]+\\)* \\(.*\\)")
	  (setq buffer-of-error (find-file-noselect
				 (buffer-substring-no-properties
				  (nth 4 (match-data t))
				  (nth 5 (match-data t))))))
	 ((looking-at ".*:.*line \\([0-9]+\\)")
	  (let ((line-of-error
		 (string-to-number (buffer-substring-no-properties
				    (nth 2 (match-data t))
				    (nth 3 (match-data t))))))
	    (setq compilation-error-list
		  (cons
		   (cons
		    (point-marker)
		    (save-excursion
		      (set-buffer buffer-of-error)
		      (goto-line line-of-error)
		      (beginning-of-line)
		      (point-marker)))
		   compilation-error-list))))
	  (t t))
	(forward-line 1)) )))

;;;; Indentation
(defun graphviz-dot-indent-line ()
  "Indent current line of dot code."
  (interactive)
  (beginning-of-line)
  (cond
   ((bobp)
    ;; simple case, indent to 0
    (indent-line-to 0))
   ((looking-at "^[ \t]*}[ \t]*$")
    ;; block closing, deindent relative to previous line
    (indent-line-to (save-excursion
		      (forward-line -1)
		      (- (current-indentation) default-tab-width))))
   ;; other cases need to look at previous lines
   (t
    (indent-line-to (save-excursion
		      (forward-line -1)
		      (cond
		       ((looking-at "\\(^.*{[^}]*$\\)")
			;; previous line opened a block
			;; indent to that line
			(+ (current-indentation) default-tab-width))
		       ((and (not (looking-at ".*\\[.*\\].*"))
			     (looking-at ".*\\[.*")) ; TODO:PP : can be 1 regex
			;; previous line started filling
			;; attributes, intend to that start
			(search-forward "[")
			(current-column))
		       ((and (not (looking-at ".*\\[.*\\].*"))
			     (looking-at ".*\\].*")) ; TODO:PP : "
			;; previous line stopped filling
			;; attributes, find the line that started
			;; filling them and indent to that line
			(while (or (looking-at ".*\\[.*\\].*")
				   (not (looking-at ".*\\[.*"))) ; TODO:PP : "
			  (forward-line -1))
			(current-indentation))
		       (t
			;; default case, indent the
			;; same as previous line
			(current-indentation)) ))) )))

(defun graphviz-dot-indent-graph ()
  "Indent the graph/digraph/subgraph where point is at.
This will first teach the beginning of the graph were point is at, and
then indent this and each subgraph in it."
  (interactive)
  (save-excursion
    ;; position point at start of graph
    (while (not (or (looking-at "\\(^.*{[^}]*$\\)") (bobp)))
      (forward-line -1))
    ;; n is the number of { encounter - the number of } encouterd
    (let ((n 0))
      (while
	  (progn
	    (cond
	     ;; update n
	     ((looking-at "\\(^.*{[^}]*$\\)")
	      (setq n (+ n 1)))
	     ;; update n
	     ((looking-at "^[ \t]*}[ \t]*$")
	      (setq n (- n 1))))
	    ;; indent this line and move on
	    (graphviz-dot-indent-line)
	    (forward-line 1)
	    ;; as long as we are not completed or at end of buffer
	    (or (> n 0) (eobp))))) ))
	   
;;;; Preview
(defun graphviz-dot-preview ()
  "Shows an example of the current dot file in an emacs buffer.
This assumes that we are running emacs under a windowing system.
See `image-file-name-extensions' for costumizing the files that can be
loaded."
  (interactive)
  ;; unsafe to compile ourself, ask it to the user
  (if (buffer-modified-p)
      (message "Buffer needs to be compiled.")
    ;; run through all the extensions for images
    (let ((l image-file-name-extensions))
      (while
	  (let ((f (concat (file-name-sans-extension (buffer-file-name))
			   "."
			   (car l))))
	    ;; see if a file matches, might be best also to check
	    ;; if file is up to date TODO:PP
	    (if (file-exists-p f)
		(progn (auto-image-file-mode 1)
		       ;; OK, this is ugly, I would need to 
		       ;; know how I can reload a file in an existing buffer
		       (if (get-buffer "*preview*")
			   (kill-buffer "*preview*"))
		       (set-buffer (find-file-noselect f))
		       (rename-buffer "*preview*")
		       (display-buffer (get-buffer "*preview*"))
		       ;; stop iterating
		       '())
	      ;; will stop iterating when l is nil
	      (setq l (cdr l)))))
      ;; each extension tested and nothing found, let user know
      (when (eq l '())
	(message "No image found.")))))
		 
      

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.dot\\'" . graphviz-dot-mode))

(provide 'graphviz-dot-mode)
;;; graphviz-dot-mode.el ends here

