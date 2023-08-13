;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; Copyright (C)

;; Author: <>

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; My init.el.

;;; Code:

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/{{pkg}}/init.el

;; Temporarily disable magic file name
(defconst my-saved-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("org"   . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :after imenu-list
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf *git-mode-line-face
  :defun vc-git-mode-line-string my-vc-git-mode-line-string
  :preface
  (defun my-vc-git-mode-line-string (orig-fn &rest args)
    "Replace Git in modeline with font-awesome git icon via ORIG-FN and ARGS."
    (let ((str (apply orig-fn args)))
      (concat
       [#xE725]
       (substring-no-properties str 4))))
  :config
  (advice-add #'vc-git-mode-line-string :around #'my-vc-git-mode-line-string))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp packages"
  :tag "builtin" "faces" "help"
  :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

(leaf files
  :custom
  ;; バックアップ先をカレントディレクトリから変更
  (backup-directory-alist . `(("" . ,(concat user-emacs-directory "file-backup/"))))
  ;; 自動保存(クラッシュ時の対応)先をカレントディレクトリから変更
  (auto-save-file-name-transforms . `((".*" ,temporary-file-directory t)))
  ;; askだと件数を超えた自動削除時時に一々聞いてくるのでtに変更
  (delete-old-versions . t)
  ;; backupに新しいものをいくつ残すか
  (kept-new-versions . 10)
  ;; backupに古いものをいくつ残すか
  (kept-old-versions . 0)
  ;; バックアップファイル %backup%~ を作成しない。
  (make-backup-files . nil)
  ;; 複数バックアップ
  (version-control . t))

(leaf *to-be-quiet
  :config
  (defalias 'yes-or-no-p #'y-or-n-p))

(leaf gcmh
  :doc "the Garbage Collector Magic Hack"
  :req "emacs-24"
  :tag "internal" "emacs>=24"
  :url "https://gitlab.com/koral/gcmh"
  :added "2023-03-08"
  :emacs>= 24
  :defvar gcmh-low-cons-threshold gcmh-high-cons-threshold
  :ensure t
  :blackout t
  :custom
  ((gcmh-verbose . t)
   (gcmh-idle-delay . 120)
   (gcmh-auto-idle-delay-factor . 60))
  :config
  (setq gcmh-low-cons-threshold (* 800000 16))
  (setq gcmh-high-cons-threshold (* 1073741824 16)))

(leaf *global-bindings
  :defun vi-open-line-above vi-open-line-below
  :init
  (global-set-key (kbd "C-\\") 'set-mark-command)
  (global-set-key (kbd "C-SPC") 'toggle-input-method)
  (define-key mozc-mode-map (kbd "C-\\") 'set-mark-command)
  (define-key mozc-mode-map (kbd "C-SPC") 'toggle-input-method)
  :preface
  (defun vi-open-line-above nil
    "Insert a newline above the current line and put point at beginning."
    (interactive)
    (unless (bolp)
      (beginning-of-line))
    (newline)
    (forward-line -1)
    (indent-according-to-mode))
  (defun vi-open-line-below nil
    "Insert a newline below the current line and put point at beginning."
    (interactive)
    (unless (eolp)
      (end-of-line))
    (newline-and-indent))
  :bind
  ("C-h" . delete-backward-char)
  ("C-S-h" . kill-whole-line)
  ("<C-S-return>" . vi-open-line-above)
  ("<C-return>" . vi-open-line-below))

(leaf view
  :doc "peruse file or buffer without editing"
  :tag "builtin"
  :added "2023-03-11"
  :bind
  (:view-mode-map
   ("j" . next-line)
   ("k" . previous-line)
   ("l" . forward-char)
   ("h" . backward-char)
   ("n" . scroll-down-command)
   ("u" . scroll-up-command)
   ("L" . forward-word)
   ("H" . backward-word)
   ("a" . mwim-beginning-of-code-or-line)
   ("e" . mwim-end-of-code-or-line)
   ("g" . beginning-of-buffer)
   ("G" . end-of-buffer)
   ("(" . backward-list)
   (")" . forward-list)
   ("." . backward-forward-next-location)
   ("," . backward-forward-previous-location)
   ("f" . posframe-hide-all)
   ("<SPC>" . recenter-top-bottom)
   ("v" . view-mode)))

(leaf *smart-kill
  :bind*
  (("M-d" . kill-word-at-point)
   ("C-w" . backward-kill-word-or-region))
  :init
  (defun kill-word-at-point ()
    (interactive)
    (let ((char (char-to-string (char-after (point)))))
      (cond
       ((string= " " char) (delete-horizontal-space))
       ((string-match "[\t\n -@\[-`{-~],.、。" char) (kill-word 1))
       (t (forward-char) (backward-word) (kill-word 1)))))
  (defun backward-kill-word-or-region (&optional arg)
    (interactive "p")
    (if (region-active-p)
        (call-interactively #'kill-region)
      (backward-kill-word arg))))

(leaf *formatting
  :custom
  (truncate-lines . nil)
  (require-final-newline . t)
  (indent-tabs-mode . nil))

(leaf tramp
  :doc "Transparent Remote Access, Multiple Protocol"
  :tag "builtin"
  :added "2023-03-23"
  :custom
  (tramp-auto-save-directory . "~/.emacs.d/.cache/tramp/")
  (tramp-chunksize           . 2048))

(leaf *scroll
  :setq ((scroll-conservatively . 1))
  :setq ((scroll-preserve-screen-position . t)))

(leaf good-scroll
  :doc "Good pixel line scrolling"
  :req "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/io12/good-scroll.el"
  :added "2023-04-06"
  :emacs>= 27.1
  :ensure t
  :config
  (good-scroll-mode))

(leaf *large-file
  :custom
  (large-file-warning-threshold . 1000000))

(leaf *delsel
  :global-minor-mode delete-selection-mode)

(leaf undo-fu
  :doc "Undo helper with redo"
  :req "emacs-25.1"
  :tag "emacs>=25.1"
  :url "https://codeberg.org/ideasman42/emacs-undo-fu"
  :added "2023-03-09"
  :emacs>= 25.1
  :ensure t
  :bind*
  ("C-/" . undo-fu-only-undo)
  ("M-/" . undo-fu-only-redo))

(leaf undo-tree
  :doc "Treat undo history as a tree"
  :req "queue-0.2" "emacs-24.3"
  :tag "tree" "history" "redo" "undo" "files" "convenience" "emacs>=24.3"
  :url "https://www.dr-qubit.org/undo-tree.html"
  :added "2023-05-06"
  :emacs>= 24.3
  :ensure t
  :after queue)

(leaf font-for-gui
  :doc "Use Nerd & Adjust font size"
  :if (display-graphic-p)
  :defun set-fonts
  :defvar jp-font-family
  :preface
  (defun set-fonts (family)
    (set-fontset-font t 'japanese-jisx0208 (font-spec :family family))
    (set-fontset-font t 'japanese-jisx0212 (font-spec :family family))
    (set-fontset-font t 'jisx0201         (font-spec :family family))
    (set-fontset-font t 'kana             (font-spec :family family))
    (set-fontset-font t 'latin  (font-spec :family family))
    (set-fontset-font t 'greek  (font-spec :family family))
    (set-fontset-font t 'arabic (font-spec :family family))
    (set-fontset-font t 'symbol (font-spec :family family))
    (set-fontset-font t '(#x1f300 . #x1fad0) (font-spec :family "Noto Color Emoji")))
  :custom
  (use-default-font-for-symbols   . nil)
  (inhibit-compacting-font-caches . t)
  (jp-font-family      . "Cica")
  (default-font-family . "Cica")
  :config
  (set-fonts jp-font-family)
  (set-face-attribute 'default nil :family jp-font-family :height 138))

(leaf display-line-numbers
  :hook (prog-mode-hook . display-line-numbers-mode)
  :custom (display-line-numbers-width . 3))

(leaf display-column-number
  :config
  (column-number-mode))

(leaf highlight-indent-guides
  :doc "Minor mode to highlight indentation"
  :req "emacs-24.1"
  :tag "emacs>=24.1"
  :url "https://github.com/DarthFennec/highlight-indent-guides"
  :added "2022-09-24"
  :emacs>= 24.1
  :ensure t
  :blackout t
  :hook (prog-mode-hook . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-auto-enabled . t)
  (highlight-indent-guides-responsive . t)
  ;; (highlight-indent-guides-method . 'bitmap)
  :config
  (if (display-graphic-p)
      (setq highlight-indent-guides-method 'bitmap)
    (setq highlight-indent-guides-method 'character))
  (highlight-indent-guides-auto-set-faces))

(leaf rainbow-mode
  :doc "Colorize color names in buffers"
  :tag "faces"
  :url "https://elpa.gnu.org/packages/rainbow-mode.html"
  :added "2023-03-11"
  :ensure t
  :blackout t
  :hook (emacs-lisp-mode-hook . rainbow-mode))

(leaf rainbow-delimiters
  :doc "Highlight brackets according to their depth"
  :tag "tools" "lisp" "convenience" "faces"
  :url "https://github.com/Fanael/rainbow-delimiters"
  :added "2023-03-12"
  :ensure t
  :hook
  prog-mode-hook
  web-mode-hook
  :custom
  (rainbow-delimiters-max-face-count . 6)
  :custom-face
  (rainbow-delimiters-depth-1-face . '((t (:foreground "#ff8ec6"))))
  (rainbow-delimiters-depth-2-face . '((t (:foreground "#c68eff"))))
  (rainbow-delimiters-depth-3-face . '((t (:foreground "#8ec6ff"))))
  (rainbow-delimiters-depth-4-face . '((t (:foreground "#8effc6"))))
  (rainbow-delimiters-depth-5-face . '((t (:foreground "#c6ff8e"))))
  (rainbow-delimiters-depth-6-face . '((t (:foreground "#ffc68e")))))

(leaf posframe
  :doc "Pop a posframe (just a frame) at point"
  :req "emacs-26.1"
  :tag "tooltip" "convenience" "emacs>=26.1"
  :url "https://github.com/tumashu/posframe"
  :added "2022-09-23"
  :emacs>= 26.1
  :ensure t)

(leaf frame-alpha
  :preface
  (defun set-alpha (alpha-num)
    "set frame parameter 'alpha"
    (interactive "nAlpha: ")
    (set-frame-parameter nil 'alpha
                         (cons alpha-num
                               '(90)))))

(leaf mozc
  :doc "minor mode to input Japanese with Mozc"
  :tag "input method" "multilingual" "mule"
  :added "2022-09-23"
  :ensure t
  :custom
  (default-input-method . "japanese-mozc")
  (mozc-leim-title . "[🌊]"))

(leaf mozc-posframe
  :el-get "Ladicle/mozc-posframe"
  :require t
  :defun mozc-posframe-register
  :custom
  (mozc-candidate-style . 'posframe)
  (mozc-cand-posframe-separator . "\t\t")
  :config
  (mozc-posframe-register)
  :custom-face
  (mozc-cand-posframe-border-face . '((t (:background "#323445"))))
  (mozc-cand-overlay-footer-face  . '((t (:foreground "#6272a4"))))
  (mozc-cand-overlay-focused-face . '((t (:background "#2b2b2b" :foreground "#e9eaf5"))))
  (mozc-cand-overlay-odd-face     . '((t (:background "#001e43" :foreground "#afafb0"))))
  (mozc-cand-overlay-even-face    . '((t (:background "#001e43" :foreground "#afafb0")))))

(leaf modus-themes
  :doc "Elegant, highly legible and customizable themes"
  :req "emacs-27.1"
  :tag "accessibility" "theme" "faces" "emacs>=27.1"
  :url "https://git.sr.ht/~protesilaos/modus-themes"
  :added "2022-09-23"
  :emacs>= 27.1
  :ensure t
  :custom
  ((modus-themes-italic-constructs . t)
   (modus-themes-bold-constructs . t)
   (modus-themes-mixed-fonts . nil)
   (modus-themes-subtle-line-numbers . t)
   (modus-themes-paren-match . '(bold intense))
   (modus-themes-region . '(no-extend bg-only))
   (modus-themes-variable-pitch-ui . nil))
  (modus-vivendi-palette-overrides
   . '((bg-main        "#1c1f29")
       (bg-dim         "#0d1117")
       (fg-main        "#e4ecf3")
       (fg-dim         "#aeb9c2")
       (comment        "#6a9955")
       (constant       "#569cd6")
       (docstring      "#ce9178")
       (docmarkup      "#888888")
       (fnname         "#dcdcaa")
       (keyword        "#569cd6")
       (string         "#ce9178")
       (type           "#4ec9b0")
       (variable       "#9cdcfe")
       (bg-paren-match "#4b474c")
       (bg-region      "#264f78")
       (bg-completion  "#5a5a5a")
       (fg-line-number-active "#00bcff")
       (bg-line-number-active unspecified)
       (bg-line-number-inactive unspecified)
       (fringe unspecified)))
  (modus-themes-common-palette-overrides
   . '((border-mode-line-active bg-mode-line-active)
       (border-mode-line-inactive bg-mode-line-inactive)))
  :config
  (load-theme 'modus-vivendi :no-confirm))

(leaf moody
  :doc "Tabs and ribbons for the mode line"
  :req "emacs-25.3" "compat-28.1.1.0"
  :tag "faces" "emacs>=25.3"
  :url "https://github.com/tarsius/moody"
  :added "2022-09-24"
  :emacs>= 25.3
  :ensure t
  :custom
  (x-underline-at-descent-line . t)
  (moody-mode-line-height . 26)
  :config
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode)
  (moody-replace-eldoc-minibuffer-message-function))

(leaf tree-sitter
  :doc "Incremental parsing system"
  :req "emacs-25.1" "tsc-0.18.0"
  :tag "tree-sitter" "parsers" "tools" "languages" "emacs>=25.1"
  :url "https://github.com/emacs-tree-sitter/elisp-tree-sitter"
  :added "2023-04-03"
  :emacs>= 25.1
  :ensure t
  :blackout t
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(leaf tree-sitter-langs
  :doc "Grammar bundle for tree-sitter"
  :req "emacs-25.1" "tree-sitter-0.15.0"
  :tag "tree-sitter" "parsers" "tools" "languages" "emacs>=25.1"
  :url "https://github.com/emacs-tree-sitter/tree-sitter-langs"
  :added "2023-04-05"
  :emacs>= 25.1
  :el-get emacs-tree-sitter/tree-sitter-langs
  :after tree-sitter)

(leaf dashboard
  :doc "A startup screen extracted from Spacemacs"
  :req "emacs-26.1"
  :tag "dashboard" "tools" "screen" "startup" "emacs>=26.1"
  :url "https://github.com/emacs-dashboard/emacs-dashboard"
  :added "2022-09-30"
  :emacs>= 26.1
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  :custom
  (dashboard-startup-banner . 'official)
  (dashboard-set-heading-icons . t)
  (dashboard-set-file-icons . t))

(leaf beacon
  :doc "Highlight the cursor whenever the window scrolls"
  :req "emacs-25.1"
  :tag "convenience" "emacs>=25.1"
  :url "https://github.com/Malabarba/beacon"
  :added "2023-04-05"
  :emacs>= 25.1
  :ensure t
  :custom (beacon-color . "#f1fa8c"))

(leaf nyan-mode
  :doc "Nyan Cat shows position in current buffer in mode-line"
  :req "emacs-24.1"
  :tag "multimedia" "mouse" "games" "convenience" "emacs>=24.1"
  :url "https://github.com/TeMPOraL/nyan-mode/"
  :added "2022-09-24"
  :emacs>= 24.1
  :ensure t
  :defun nyan-start-animation
  :custom
  (nyan-wavy-trail . t)
  (nyan-animate-nyancat . t)
  :hook
  (prog-mode-hook . nyan-mode))

(leaf flycheck
  :doc "On-the-fly syntax checking"
  :req "dash-2.12.1" "pkg-info-0.4" "let-alist-1.0.4" "seq-1.11" "emacs-24.3"
  :tag "tools" "languages" "convenience" "emacs>=24.3"
  :url "http://www.flycheck.org"
  :added "2022-09-27"
  :emacs>= 24.3
  :ensure t
  :blackout t
  :global-minor-mode global-flycheck-mode
  :custom
  (flycheck-display-errors-delay . 0))

(leaf which-key
  :doc "Display available keybindings in popup"
  :req "emacs-24.4"
  :tag "emacs>=24.4"
  :url "https://github.com/justbur/emacs-which-key"
  :added "2022-09-25"
  :emacs>= 24.4
  :ensure t
  :blackout t
  :global-minor-mode which-key-mode
  )

(leaf yasnippet
  :doc "Yet another snippet extension for Emacs"
  :req "cl-lib-0.5"
  :tag "emulation" "convenience"
  :url "http://github.com/joaotavora/yasnippet"
  :added "2023-03-07"
  :ensure t
  :blackout yas-minor-mode
  :hook   (prog-mode-hook . yas-minor-mode)
  :bind
  (:yas-minor-mode-map
   ("C-'" . yas-expand))
  :custom (yas-snippet-dirs . '("~/.emacs.d/snippets"))
  :config
  (yas-reload-all))

(leaf yasnippet-snippets
  :doc "Collection of yasnippet snippets"
  :req "yasnippet-0.8.0"
  :tag "snippets"
  :url "https://github.com/AndreaCrotti/yasnippet-snippets"
  :added "2023-04-04"
  :ensure t)

(leaf yasnippet-org
  :tag "out-of-MELPA"
  :added "2023-04-04"
  :el-get takeokunn/yasnippet-org
  :require t)

(leaf corfu
  :doc "Completion Overlay Region FUnction"
  :req "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/minad/corfu"
  :added "2022-09-24"
  :emacs>= 27.1
  :ensure t
  :init
  (global-corfu-mode)
  :bind
  (:corfu-map
   ("<remap> <next-line>" . nil)
   ("<remap> <previous-line>" . nil))
  :custom
  (corfu-auto . t)
  (corfu-cycle . t)
  (corfu-preselect . 'prompt)
  )

(leaf corfu-terminal
  :tag "out-of-MELPA"
  :added "2022-09-24"
  :el-get (corfu-terminal :url "https://codeberg.org/akib/emacs-corfu-terminal.git")
  :unless (display-graphic-p)
  :after popon
  :defun corfu-terminal-mode
  :init
  (corfu-terminal-mode +1))

(leaf popon
  :tag "out-of-MELPA"
  :added "2022-09-24"
  :el-get (popon :url "https://codeberg.org/akib/emacs-popon.git")
  :unless (display-graphic-p)
  :require t)

(leaf cape
  :doc "Completion At Point Extensions"
  :req "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/minad/cape"
  :added "2022-09-24"
  :emacs>= 27.1
  :defun my/lsp-capf
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-file t)
  (add-to-list 'completion-at-point-functions #'cape-tex t)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev t)
  (add-to-list 'completion-at-point-functions #'cape-keyword t)
  (add-to-list 'completion-at-point-functions #'cape-abbrev t)
  (add-to-list 'completion-at-point-functions #'cape-ispell t)
  (add-to-list 'completion-at-point-functions #'cape-symbol t)
  (defun my/lsp-capf ()
    (setq-local completion-at-point-functions
                (list (cape-super-capf
                       #'lsp-completion-at-point
                       #'cape-yasnippet))))
  (add-hook 'lsp-completion-mode-hook #'my/lsp-capf))

(leaf cape-yasnippet
  :tag "out-of-MELPA"
  :added "2023-04-04"
  :el-get elken/cape-yasnippet
  :defun cape-yasnippet
  :require t
  :after cape)

(leaf vertico
  :doc "VERTical Interactive COmpletion"
  :req "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/minad/vertico"
  :added "2022-09-24"
  :emacs>= 27.1
  :global-minor-mode vertico-mode
  :ensure t
  :custom
  (vertico-cycle . t)
  (vertico-count . 18))

(leaf vertico-posframe
  :doc "Using posframe to show Vertico"
  :req "emacs-26.0" "posframe-1.1.4" "vertico-0.13.0"
  :tag "vertico" "matching" "convenience" "abbrev" "emacs>=26.0"
  :url "https://github.com/tumashu/vertico-posframe"
  :added "2022-09-24"
  :emacs>= 26.0
  :if (display-graphic-p)
  :global-minor-mode vertico-posframe-mode
  :ensure t
  :custom
  (vertico-posframe-border-width . 5)
  (vertico-posframe-parameters
   . '((left-fringe . 8)
       (right-fringe . 8)))
  :custom-face
  (vertico-posframe-border . '((t (:background "#778899")))))

(leaf consult
  :doc "Consulting completing-read"
  :req "emacs-27.1" "compat-28.1"
  :tag "emacs>=27.1"
  :url "https://github.com/minad/consult"
  :added "2022-09-24"
  :emacs>= 27.1
  :ensure t
  :bind
  ("M-y" . consult-yank-pop)
  ("C-M-s" . consult-line)
  ("C-x b" . consult-buffer)
  ("C-M-o" . consult-outline)
  :custom
  (consult-async-mininput . 1))

(leaf consult-flycheck
  :doc "Provides the command `consult-flycheck'"
  :req "consult-0.16" "flycheck-31" "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/minad/consult"
  :added "2022-09-27"
  :emacs>= 27.1
  :ensure t)

(leaf consult-custom
  :doc "Custom functions to search org documents"
  :after affe
  :require affe
  :preface
  (defun consult-find-doc ()
    "Search org files in the private document directory."
    (interactive)
    (let ((affe-find-command "fdfind --ignore-case --extension org --no-ignore ."))
      (funcall #'affe-find org-directory)))
  (defun consult-grep-doc ()
    "Search text in the private document directory"
    (interactive)
    (let ((affe-grep-command "rg --null --color=never --max-columns=1000 --ignore-case --no-ignore --no-heading --line-number -v ^$ ."))
      (funcall #'affe-grep org-directory))))

(leaf affe
  :doc "Asynchronous Fuzzy Finder for Emacs"
  :req "emacs-27.1" "consult-0.16"
  :tag "emacs>=27.1"
  :url "https://github.com/minad/affe"
  :added "2022-09-27"
  :emacs>= 27.1
  :ensure t
  :after consult)

(leaf marginalia
  :doc "Enrich existing commands with completion annotations"
  :req "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/minad/marginalia"
  :added "2022-09-24"
  :emacs>= 27.1
  :global-minor-mode marginalia-mode
  :ensure t
  :custom-face
  (marginalia-documentation . '((t (:foreground "#6272a4")))))

(leaf orderless
  :doc "Completion style for matching regexps in any order"
  :req "emacs-26.1"
  :tag "extensions" "emacs>=26.1"
  :url "https://github.com/oantolin/orderless"
  :added "2022-09-24"
  :emacs>= 26.1
  :ensure t
  :preface
  (defun flex-if-apostrophe (pattern _index _total)
    (when (string-suffix-p "'" pattern)
      `(orderless-flex . ,(substring pattern 0 -1))))
  (defun without-if-bang (pattern _index _total)
    (cond
     ((equal "!" pattern)
      '(orderless-literal . ""))
     ((string-prefix-p "!" pattern)
      `(orderless-without-literal . ,(substring pattern 1)))))
  :custom
  (completion-styles . '(orderless))
  (orderless-style-dispatchers . '(flex-if-apostrophe
                                   without-if-bang)))

(leaf kind-icon
  :doc "Completion kind icons"
  :req "emacs-27.1" "svg-lib-0"
  :tag "completion" "emacs>=27.1"
  :url "https://github.com/jdtsmith/kind-icon"
  :added "2022-09-24"
  :el-get "jdtsmith/kind-icon"
  :emacs>= 27.1
  ;; :ensure t
  :defvar corfu-margin-formatters
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(leaf all-the-icons
  :doc "A library for inserting Developer icons"
  :req "emacs-24.3"
  :tag "lisp" "convenient" "emacs>=24.3"
  :url "https://github.com/domtronn/all-the-icons.el"
  :added "2022-09-29"
  :emacs>= 24.3
  :ensure t)

;; (leaf eglot
;;   :doc "Client for Language Server Protocol (LSP) servers"
;;   :req "emacs-26.1" "jsonrpc-1.0.14" "flymake-1.2.1" "project-0.3.0" "xref-1.0.1" "eldoc-1.11.0" "seq-2.23"
;;   :tag "languages" "convenience" "emacs>=26.1"
;;   :url "https://github.com/joaotavora/eglot"
;;   :added "2022-09-27"
;;   :emacs>= 26.1
;;   :ensure t
;;   :custom
;;   completion-category-defaults . nil)

;; (leaf lsp-bridge
;;   :tag "out-of-MELPA"
;;   :added "2023-03-07"
;;   :el-get manateelazycat/lsp-bridge
;;   :init
;;   (yas-global-mode 1)
;;   :require yasnippet lsp-bridge
;;   :config
;;   (global-lsp-bridge-mode))

(leaf lsp-mode
  :doc "LSP mode"
  :req "emacs-26.1" "dash-2.18.0" "f-0.20.0" "ht-2.3" "spinner-1.7.3" "markdown-mode-2.3" "lv-0"
  :tag "languages" "emacs>=26.1"
  :url "https://github.com/emacs-lsp/lsp-mode"
  :added "2022-09-27"
  :emacs>= 26.1
  :ensure t
  :custom
  ;; General settings
  (lsp-auto-guess-root                . t)
  (lsp-modeline-diagnostics-enable    . t)
  (lsp-headerline-breadcrumb-enable   . t)
  ;; Performance tuning
  (lsp-log-io               . nil)
  (lsp-print-performance    . nil)
  (lsp-completion-provider  . :none)
  (lsp-enable-file-watchers . nil)
  (lsp-idle-delay           . 0.500)
  (gc-cons-threshold        . 100000000)
  (read-process-output-max  . 1048576)
  :init
  (defun lsp-format-before-save ()
    "保存する前にフォーマットする"
    (add-hook 'before-save-hook 'lsp-format-buffer nil t))
  :bind
  (:lsp-mode-map
   ("C-c r"   . lsp-rename)
   ("C-c C-c" . lsp-execute-code-action)
   ("C-c f"   . lsp-format-buffer))
  :hook
  (prog-major-mode . lsp-prog-major-mode-enable)
  (latex-mode . lsp-prog-major-mode-enable)
  ;; (before-save-hook . lsp-format-buffer)
  )

(leaf lsp-ui
  :doc "UI integrations for lsp-mode"
  :url "https://github.com/emacs-lsp/lsp-ui"
  :ensure t
  :hook (lsp-mode-hook . lsp-ui-mode)
  :custom
  (lsp-ui-flycheck-enable     . t)
  (lsp-ui-sideline-enable     . t)
  (lsp-ui-sideline-show-symbol . t)
  (lsp-ui-sideline-show-hover . t)
  (lsp-ui-imenu-enable        . nil)
  (lsp-ui-peek-fontify        . 'on-demand)
  (lsp-ui-peek-enable         . t)
  (lsp-ui-doc-enable          . nil)
  (lsp-ui-doc-max-height      . 12)
  (lsp-ui-doc-max-width       . 56)
  (lsp-ui-doc-position        . 'at-point)
  (lsp-ui-doc-border          . "#323445")
  :custom-face
  (lsp-ui-doc-background . '((t (:background "#282a36"))))
  (lsp-ui-doc-header     . '((t (:foreground "#76e0f3" :weight bold))))
  (lsp-ui-doc-url        . '((t (:foreground "#6272a4"))))
  :bind
  ((:lsp-mode-map
    ("C-c C-r"   . lsp-ui-peek-find-references)
    ("C-c C-j"   . lsp-ui-peek-find-definitions)
    ("C-c C-M-j" . xref-find-definitions-other-window)
    ("C-c i"     . lsp-ui-peek-find-implementation)
    ("C-c m"     . counsel-imenu)
    ("C-c M"     . lsp-ui-imenu)
    ("C-c s"     . toggle-lsp-ui-sideline)
    ("C-c d"     . toggle-lsp-ui-doc))
   (:lsp-ui-doc-mode-map
    ("q"         . toggle-lsp-ui-doc)
    ("C-i"       . lsp-ui-doc-focus-frame)))
  :init
  (defun toggle-lsp-ui-sideline ()
    (interactive)
    (if lsp-ui-sideline-show-hover
        (progn
          (setq lsp-ui-sideline-show-hover nil)
          (message "sideline-hover disabled :P"))
      (progn        (setq lsp-ui-sideline-show-hover t)
                    (message "sideline-hover enabled :)"))))
  (defun toggle-lsp-ui-doc ()
    (interactive)
    (if lsp-ui-doc-mode
        (progn
          (lsp-ui-doc-mode -1)
          (lsp-ui-doc--hide-frame)
          (message "lsp-ui-doc disabled :P"))
      (progn
        (lsp-ui-doc-mode 1)
        (message "lsp-ui-doc enabled :)")))))

;; Debugger
(leaf dap-mode
  :doc "Client for Debug Adapter Protocol"
  :url "https://emacs-lsp.github.io/dap-mode/"
  :ensure t
  )

(leaf dap-gdb-lldb
  :doc "Debug Adapter Protocol mode for LLDB/GDB"
  :tag "out-of-MELPA" "languages"
  :url "https://github.com/yyoncho/dap-mode"
  :added "2023-04-03"
  :el-get "WebFreak001/code-debug"
  :require t)

;; C/C++/Objective-C
(leaf cc-mode
  :doc "Mode for C, C++, Objective-C, Java, CORBA IDL (and the variants PSDL and CIDL), Pike and AWK code"
  :url "https://www.gnu.org/software/emacs/manual/html_mono/ccmode.html"
  :ensure t
  :custom (c-base-offset . 4)
  :bind   (:c-mode-base-map ("C-c C-n" . compile))
  :hook   (c-mode-common-hook
           . (lambda ()
               (lsp-deferred)
               (c-set-style "stroustrup"))))

(leaf ccls
  :doc "ccls client"
  :url "https://github.com/emacs-lsp/emacs-ccls"
  :ensure t
  :require ccls
  :custom `((ccls-executable . ,(executable-find "ccls"))))

(leaf modern-cpp-font-lock
  :doc "Syntax highlighting support for `Modern C++' - until C++20 and Technical Specification"
  :url "https://github.com/ludwigpacifici/modern-cpp-font-lock"
  :ensure t
  :blackout t
  :config (modern-c++-font-lock-global-mode t))

(leaf clang-format
  :doc "Format code using clang-format"
  :req "cl-lib-0.3"
  :tag "c" "tools"
  :added "2023-01-05"
  :ensure t)

;; Haskell
(leaf haskell-mode
  :doc "A Haskell editing mode"
  :req "emacs-25.1"
  :tag "haskell" "files" "faces" "emacs>=25.1"
  :url "https://github.com/haskell/haskell-mode"
  :added "2023-07-06"
  :emacs>= 25.1
  :ensure t
  :hook
  (haskell-mode-hook . lsp-mode)
  (haskell-literate-mode-hook . lsp-mode)
  :custom
  (lsp-haskell-formatting-provider . "fourmolu")
  (haskell-indentation-layout-offset . 4)
  (haskell-indentation-starter-offset . 4)
  (haskell-indentation-left-offset . 4)
  (haskell-indentation-where-pre-offset . 4)
  (haskell-indentation-where-post-offset . 4))

(leaf lsp-haskell
  :doc "Haskell support for lsp-mode"
  :req "emacs-24.3" "lsp-mode-3.0" "haskell-mode-16.1"
  :tag "haskell" "emacs>=24.3"
  :url "https://github.com/emacs-lsp/lsp-haskell"
  :added "2023-07-06"
  :emacs>= 24.3
  :ensure t
  :after lsp-mode haskell-mode)

;; Perl
(leaf perl-mode
  :doc "Perl code editing commands for GNU Emacs"
  :tag "builtin"
  :added "2023-05-21"
  :hook (perl-mode-hook . lsp-mode))

;; Python
(leaf lsp-pyright
  :doc "Python LSP client using Pyright"
  :req "emacs-26.1" "lsp-mode-7.0" "dash-2.18.0" "ht-2.0"
  :tag "lsp" "tools" "languages" "emacs>=26.1"
  :url "https://github.com/emacs-lsp/lsp-pyright"
  :added "2023-05-21"
  :emacs>= 26.1
  :ensure t
  :after lsp-mode
  :hook (python-mode-hook . (lambda ()
                              (require 'lsp-pyright)
                              (lsp-deferred))))

(leaf blacken
  :doc "Reformat python buffers using the \"black\" formatter"
  :req "emacs-25.2"
  :tag "emacs>=25.2"
  :url "https://github.com/proofit404/blacken"
  :added "2023-05-21"
  :emacs>= 25.2
  :ensure t
  :bind
  (:lsp-mode-map
   ("C-c f" . blacken-buffer))
  :hook (python-mode-hook . blacken-mode)
  :custom ((blacken-line-length . 119)
           (blacken-skip-string-normalization . t)))

(leaf exec-path-from-shell
  :doc "Get environment variables such as $PATH from the shell"
  :req "emacs-24.1" "cl-lib-0.6"
  :tag "environment" "unix" "emacs>=24.1"
  :url "https://github.com/purcell/exec-path-from-shell"
  :added "2022-10-05"
  :emacs>= 24.1
  :ensure t
  :config
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "PATH"))

(leaf multi-compile
  :doc "Multi target interface to compile."
  :req "emacs-24.4" "dash-2.12.1"
  :tag "build" "compile" "tools" "emacs>=24.4"
  :url "https://github.com/ReanGD/emacs-multi-compile"
  :added "2023-04-04"
  :emacs>= 24.4
  :defvar multi-compile-alist
  :ensure t
  :bind ("C-S-b" . multi-compile-run)
  :init
  (add-hook 'compilation-finish-functions 'switch-to-buffer-other-window 'compilation)
  :setq ((multi-compile-alist quote
                              ((c++-mode
                                ("c++-atcode" . "g++ -std=gnu++17 -Wall -Wextra -O2 -DONLINE_JUDGE -I/opt/boost/gcc/include -L/opt/boost/gcc/lib -I$HOME/ac-library -o ./a.out %file-name"))))))

(leaf doxymacs
  :tag "out-of-MELPA"
  :added "2023-05-29"
  :el-get dpom/doxymacs
  :require t
  :hook
  (c-mode-common-hook . doxymacs-mode)
  (font-lock-mode-hook .
                       (lambda ()
                         (when (memq major-mode '(c-mode c++-mode))
                           (doxymacs-font-lock))))
  :custom (doxymacs-doxygen-style . "JavaDoc"))

(leaf markdown-mode
  :doc "Major mode for Markdown-formatted text"
  :req "emacs-26.1"
  :tag "itex" "github flavored markdown" "markdown" "emacs>=26.1"
  :url "https://jblevins.org/projects/markdown-mode/"
  :added "2023-03-07"
  :emacs>= 26.1
  :ensure t
  :hook   (prog-mode-hook . yas-minor-mode)
  :custom (yas-snippet-dirs . '("~/.emacs.d/snippets"))
  :config (yas-reload-all))

(leaf imenu-list
  :doc "Show imenu entries in a separate buffer"
  :req "emacs-24.3"
  :tag "emacs>=24.3"
  :url "https://github.com/bmag/imenu-list"
  :added "2022-09-30"
  :emacs>= 24.3
  :bind ("<f10>" . imenu-list-smart-toggle)
  :hook (imenu-list-major-mode-hook . neo-hide-nano-header)
  :custom
  (imenu-list-auto-resize . t)
  (imenu-list-focus-after-activation . t)
  (imenu-list-entry-prefix   . "•")
  (imenu-list-subtree-prefix . "•")
  :custom-face
  (imenu-list-entry-face-1          . '((t (:foreground "white"))))
  (imenu-list-entry-subalist-face-0 . '((nil (:weight normal))))
  (imenu-list-entry-subalist-face-1 . '((nil (:weight normal))))
  (imenu-list-entry-subalist-face-2 . '((nil (:weight normal))))
  (imenu-list-entry-subalist-face-3 . '((nil (:weight normal)))))

(leaf backward-forward
  :doc "navigation backwards and forwards across marks"
  :req "emacs-24.5"
  :tag "forward" "backward" "convenience" "navigation" "emacs>=24.5"
  :url "https://gitlab.com/vancan1ty/emacs-backward-forward/tree/master"
  :added "2023-03-11"
  :emacs>= 24.5
  :ensure t)

(leaf major-mode-hydra
  :doc "Major mode keybindings managed by Hydra"
  :req "dash-2.18.0" "pretty-hydra-0.2.2" "emacs-25"
  :tag "emacs>=25"
  :url "https://github.com/jerrypnz/major-mode-hydra.el"
  :added "2023-03-09"
  :emacs>= 25
  :ensure t
  :after pretty-hydra)

(leaf hydra-posframe
  :doc "Show hidra hints on posframe"
  :tag "out-of-MELPA"
  :url "https://github.com/Ladicle/hydra-posframe"
  :added "2023-03-09"
  :el-get Ladicle/hydra-posframe
  :if (display-graphic-p)
  :global-minor-mode hydra-posframe-mode
  :custom
  (hydra-posframe-border-width . 5)
  (hydra-posframe-parameters   . '((left-fringe . 8) (right-fringe . 8)))
  :custom-face
  (hydra-posframe-border-face . '((t (:background "#323445")))))

(leaf *hydra-goto
  :doc "Search and move cursor"
  :bind ("M-p" . *hydra-goto/body)
  :pretty-hydra
  ((:title " Goto" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Got"
    (("i" avy-goto-char       "char")
     ("t" avy-goto-char-timer "timer")
     ("w" avy-goto-word-1     "word")
     ("j" avy-resume "resume"))
    "Line"
    (("h" avy-goto-line        "head")
     ("e" avy-goto-end-of-line "end")
     ("n" consult-goto-line    "number"))
    "Topic"
    (("o"  consult-outline      "outline")
     ("m"  consult-imenu        "imenu")
     ("gm" consult-imenu-multi  "global imenu"))
    "Error"
    ((","  flycheck-previous-error "previous" :exit nil)
     ("."  flycheck-next-error "next" :exit nil)
     ("l" consult-flycheck "list"))
    "Spell"
    ((">"  flyspell-goto-next-error "next" :exit nil)
     ("cc" flyspell-correct-at-point "correct" :exit nil)))))

(leaf *hydra-toggle
  :doc "Toggle functions"
  :bind ("M-t" . *hydra-toggle/body)
  :pretty-hydra
  ((:title " Toggle" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Basic"
    (("v" view-mode "view mode" :toggle t)
     ("w" whitespace-mode "whitespace" :toggle t)
     ("W" whitespace-cleanup "whitespace cleanup")
     ("r" rainbow-mode "rainbow" :toggle t)
     ("b" beacon-mode "beacon" :toggle t))
    "Line & Column"
    (("l" toggle-truncate-lines "truncate line" :toggle t)
     ("n" display-line-numbers-mode "line number" :toggle t)
     ("f" display-fill-column-indicator-mode "column indicator" :toggle t)
     ("c" visual-fill-column-mode "visual column" :toggle t))
    "Highlight"
    (("h" highlight-symbol "highligh symbol" :toggle t)
     ("L" hl-line-mode "line" :toggle t)
     ("t" hl-todo-mode "todo" :toggle t)
     ("g" git-gutter-mode "git gutter" :toggle t)
     ("i" highlight-indent-guides-mode "indent guide" :toggle t))
    "Window"
    (("t" toggle-window-transparency "transparency" :toggle t)
     ("m" toggle-window-maximize "maximize" :toggle t)
     ("p" presentation-mode "presentation" :toggle t)))))

(leaf *hydra-search
  :doc "Search functions"
  :bind
  ("M-s" . *hydra-search/body)
  :pretty-hydra
  ((:title " Search" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Buffer"
    (("l" consult-line "line")
     ("o" consult-outline "outline")
     ("m" consult-imenu "imenu"))
    "Project"
    (("f" affe-find "find")
     ("r" affe-grep "grep"))
    "Document"
    (("df" consult-find-doc "find")
     ("dd" consult-grep-doc "grep")))))

(leaf *hydra-git
  :bind
  ("M-g" . *hydra-git/body)
  :pretty-hydra
  ((:title " Git" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Basic"
    (("w" magit-checkout "checkout")
     ("s" magit-status "status")
     ("b" magit-branch "branch")
     ("F" magit-pull "pull")
     ("f" magit-fetch "fetch")
     ("A" magit-apply "apply")
     ("c" magit-commit "commit")
     ("P" magit-push "push"))
    ""
    (("d" magit-diff "diff")
     ("l" magit-log "log")
     ("r" magit-rebase "rebase")
     ("z" magit-stash "stash")
     ("!" magit-run "run shell command")
     ("y" magit-show-refs "references"))
    "Hunk"
    (("," git-gutter:previous-hunk "previous" :exit nil)
     ("." git-gutter:next-hunk "next" :exit nil)
     ("g" git-gutter:stage-hunk "stage")
     ("v" git-gutter:revert-hunk "revert")
     ("p" git-gutter:popup-hunk "popup"))
    " GitHub"
    (("C" checkout-gh-pr "checkout PR")
     ("o" browse-at-remote-or-copy"browse at point")
     ("O" (shell-command "hub browse") "browse repository")))))

(leaf *hydra-viewer
  :doc "Viewer mode like vi"
  :bind ("M-l" . *hydra-viewer/body)
  :preface
  :pretty-hydra
  ((:title " View" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Char/Line"
    (("j" scroll-down-in-place "down" :exit nil)
     ("k" scroll-up-in-place   "up" :exit nil)
     ("l" forward-char         "right" :exit nil)
     ("h" backward-char        "left" :exit nil))
    "Word/Page"
    (("n" scroll-down-command "down" :exit nil)
     ("u" scroll-up-command   "up" :exit nil)
     ("L" forward-word        "right" :exit nil)
     ("H" backward-word       "left" :exit nil))
    "Line/Buff"
    (("a" mwim-beginning-of-code-or-line "home" :exit nil)
     ("e" mwim-end-of-code-or-line       "end" :exit nil)
     ("g" beginning-of-buffer            "head" :exit nil)
     ("G" end-of-buffer                  "tail" :exit nil))
    "Paren"
    (("(" backward-list                      "back" :exit nil)
     (")" forward-list                       "forward" :exit nil)
     ("." backward-forward-next-location     "next" :exit nil)
     ("," backward-forward-previous-location "prev" :exit nil))
    "View"
    (("f" posframe-hide-all       "hide")
     ("<SPC>" recenter-top-bottom "center" :exit nil)))))

(leaf smartparens
  :doc "Automatic insertion, wrapping and paredit-like navigation with user defined pairs."
  :req "dash-2.13.0" "cl-lib-0.3"
  :tag "editing" "convenience" "abbrev"
  :url "https://github.com/Fuco1/smartparens"
  :added "2022-09-26"
  :ensure t
  :require smartparens-config
  :blackout t
  :defun sp-local-pair
  :global-minor-mode smartparens-global-mode
  :bind
  (:smartparens-mode-map
   ("M-<DEL>" . sp-backward-unwrap-sexp)
   ("M-]"     . sp-up-sexp)
   ("M-["     . sp-down-sexp)
   ("C-("     . sp-beginning-of-sexp)
   ("C-)"     . sp-end-of-sexp)
   ("C-M-f"   . sp-forward-sexp)
   ("C-M-b"   . sp-backward-sexp)
   ("C-M-n"   . sp-next-sexp)
   ("C-M-p"   . sp-previous-sexp))
  :config
  (sp-local-pair 'org-mode "*" "*")
  (sp-local-pair 'org-mode "=" "=")
  (sp-local-pair 'org-mode "~" "~")
  (sp-local-pair 'org-mode "+" "+")
  :custom
  (sp-highlight-pair-overlay . nil))

(leaf anzu
  :doc "Show number of matches in mode-line while searching"
  :req "emacs-25.1"
  :tag "emacs>=25.1"
  :url "https://github.com/emacsorphanage/anzu"
  :added "2022-09-25"
  :emacs>= 25.1
  :ensure t
  :bind
  ("M-r" . anzu-query-replace-regexp))

(leaf projectile
  :doc "Manage and navigate projects in Emacs easily"
  :req "emacs-25.1"
  :tag "convenience" "project" "emacs>=25.1"
  :url "https://github.com/bbatsov/projectile"
  :added "2022-09-29"
  :emacs>= 25.1
  :ensure t
  :global-minor-mode projectile-mode
  :bind
  (projectile-mode-map
   ("C-." . projectile-next-project-buffer)
   ("C-," . projectile-previous-project-buffer)
   ("C-c p" . projectile-command-map)))

(leaf git-modes
  :doc "Major modes for editing Git configuration files"
  :req "emacs-25.1"
  :tag "git" "vc" "convenience" "emacs>=25.1"
  :url "https://github.com/magit/git-modes"
  :added "2022-09-29"
  :emacs>= 25.1
  :ensure t)

(leaf magit
  :doc "A Git porcelain inside Emacs."
  :req "emacs-25.1" "compat-28.1.1.2" "dash-20210826" "git-commit-20220222" "magit-section-20220325" "transient-20220325" "with-editor-20220318"
  :tag "vc" "tools" "git" "emacs>=25.1"
  :url "https://github.com/magit/magit"
  :added "2022-09-29"
  :emacs>= 25.1
  :ensure t)

(leaf git-gutter
  :doc "Port of Sublime Text plugin GitGutter"
  :req "emacs-25.1"
  :tag "emacs>=25.1"
  :url "https://github.com/emacsorphanage/git-gutter"
  :added "2022-09-30"
  :emacs>= 25.1
  :ensure t
  :blackout t
  :global-minor-mode global-git-gutter-mode
  :custom
  (git-gutter:modified-sign . "┃")
  (git-gutter:added-sign    . "┃")
  (git-gutter:deleted-sign  . "┃")
  :custom-face
  (git-gutter:modified . '((t (:foreground "#f1fa8c"))))
  (git-gutter:added    . '((t (:foreground "#50fa7b"))))
  (git-gutter:deleted  . '((t (:foreground "#ff79c6")))))

(leaf treemacs
  :doc "A tree style file explorer package"
  :req "emacs-26.1" "cl-lib-0.5" "dash-2.11.0" "s-1.12.0" "ace-window-0.9.0" "pfuture-1.7" "hydra-0.13.2" "ht-2.2" "cfrs-1.3.2"
  :tag "emacs>=26.1"
  :url "https://github.com/Alexander-Miller/treemacs"
  :added "2022-09-29"
  :emacs>= 26.1
  :ensure t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :hook (treemacs-mode-hook . neo-hide-nano-header)
  :preface
  (defun neo-hide-nano-header ()
    "Hide nano header."
    (interactive)
    (setq header-line-format ""))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  ("M-0"       . treemacs-select-window)
  ("C-x t 1"   . treemacs-delete-other-windows)
  ("C-x t t"   . treemacs)
  ("C-x t d"   . treemacs-select-directory)
  ("C-x t B"   . treemacs-bookmark)
  ("C-x t C-t" . treemacs-find-file)
  ("C-x t M-t" . treemacs-find-tag))

(leaf treemacs-projectile
  :doc "Projectile integration for treemacs"
  :req "emacs-26.1" "projectile-0.14.0" "treemacs-0.0"
  :tag "emacs>=26.1"
  :url "https://github.com/Alexander-Miller/treemacs"
  :added "2022-09-29"
  :emacs>= 26.1
  :ensure t)

(leaf treemacs-icons-dired
  :doc "Treemacs icons for dired"
  :req "treemacs-0.0" "emacs-26.1"
  :tag "emacs>=26.1"
  :url "https://github.com/Alexander-Miller/treemacs"
  :added "2022-09-29"
  :emacs>= 26.1
  :ensure t
  :config
  (treemacs-icons-dired-mode))

(leaf treemacs-all-the-icons
  :doc "all-the-icons integration for treemacs"
  :req "emacs-26.1" "all-the-icons-4.0.1" "treemacs-0.0"
  :tag "emacs>=26.1"
  :url "https://github.com/Alexander-Miller/treemacs"
  :added "2022-09-29"
  :emacs>= 26.1
  :ensure t)

(leaf treemacs-magit
  :doc "Magit integration for treemacs"
  :req "emacs-26.1" "treemacs-0.0" "pfuture-1.3" "magit-2.90.0"
  :tag "emacs>=26.1"
  :url "https://github.com/Alexander-Miller/treemacs"
  :added "2022-09-30"
  :emacs>= 26.1
  :ensure t)

(leaf lsp-treemacs
  :doc "LSP treemacs"
  :req "emacs-26.1" "dash-2.18.0" "f-0.20.0" "ht-2.0" "treemacs-2.5" "lsp-mode-6.0"
  :tag "languages" "emacs>=26.1"
  :url "https://github.com/emacs-lsp/lsp-treemacs"
  :added "2022-10-05"
  :emacs>= 26.1
  :ensure t
  :config
  (lsp-treemacs-sync-mode 1))

(leaf vterm
  :doc "Fully-featured terminal emulator"
  :req "emacs-25.1"
  :tag "terminals" "emacs>=25.1"
  :url "https://github.com/akermu/emacs-libvterm"
  :added "2022-09-29"
  :emacs>= 25.1
  :ensure t
  :bind
  ("C-j" . vterm-toggle)
  (vterm-mode-map
   ("C-M-j" . my/vterm-new-buffer-in-current-window)
   ("<C-return>" . vterm-toggle-insert-cd)
   ([remap projectile-previous-project-buffer] . vterm-toggle-forward)
   ([remap projectile-next-project-buffer] . vterm-toggle-backward))
  :custom
  (vterm-max-scrollback . 10000)
  (vterm-buffer-name-string . "vterm: %s")
  (vterm-keymap-exceptions
   . '("<f1>" "<f2>" "C-c" "C-x" "C-u" "C-g" "C-l" "M-x" "M-o" "C-v" "M-v" "C-y" "M-y" "C-o" "C-j" "C-M-j")))

(leaf vterm-toggle
  :doc "Toggles between the vterm buffer and other buffers."
  :req "emacs-25.1" "vterm-0.0.1"
  :tag "terminals" "vterm" "emacs>=25.1"
  :url "https://github.com/jixiuf/vterm-toggle"
  :added "2022-09-29"
  :emacs>= 25.1
  :ensure t
  :custom
  (vterm-toggle-scope . 'project)
  :config
  ;; Show vterm buffer in the window located at bottom
  (add-to-list 'display-buffer-alist
               '((lambda(bufname _) (with-current-buffer bufname (equal major-mode 'vterm-mode)))
                 ;; (display-buffer-reuse-window display-buffer-in-direction)
                 (display-buffer-reuse-window display-buffer-in-side-window)
                 (side . right)
                 ;; (direction . bottom)
                 (reusable-frames . visible)
                 (window-height . 0.35)
                 (window-width . 0.5)))
  ;; Above display config affects all vterm command, not only vterm-toggle
  (defun my/vterm-new-buffer-in-current-window()
    (interactive)
    (let ((display-buffer-alist nil))
      (vterm))))

(leaf hide-mode-line
  :doc "minor mode that hides/masks your modeline"
  :req "emacs-24.4"
  :tag "mode-line" "frames" "emacs>=24.4"
  :url "https://github.com/hlissner/emacs-hide-mode-line"
  :added "2022-09-30"
  :emacs>= 24.4
  :ensure t
  :hook
  ((treemacs-mode-hook imenu-list-major-mode-hook lsp-ui-imenu-mode-hook) . hide-mode-line-mode))

(leaf mwim
  :doc "Switch between the beginning/end of line or code"
  :tag "convenience"
  :url "https://github.com/alezost/mwim.el"
  :added "2022-09-26"
  :ensure t
  :bind*
  (("C-a" . mwim-beginning-of-code-or-line)
   ("C-e" . mwim-end-of-code-or-line)))

(leaf comment-dwim-2
  :doc "An all-in-one comment command to rule them all"
  :req "emacs-24.4"
  :tag "convenience" "emacs>=24.4"
  :url "https://github.com/remyferre/comment-dwim-2"
  :added "2023-03-09"
  :emacs>= 24.4
  :ensure t
  :bind*
  (("M-;" . comment-dwim-2)))

(leaf easy-kill
  :doc "kill & mark things easily"
  :req "emacs-25" "cl-lib-0.5"
  :tag "convenience" "killing" "emacs>=25"
  :url "https://github.com/leoliu/easy-kill"
  :added "2022-09-30"
  :emacs>= 25
  :ensure t
  :bind
  ("M-w" . easy-kill))

(leaf avy
  :doc "Jump to arbitrary positions in visible text and select text quickly."
  :req "emacs-24.1" "cl-lib-0.5"
  :tag "location" "point" "emacs>=24.1"
  :url "https://github.com/abo-abo/avy"
  :added "2022-09-26"
  :emacs>= 24.1
  :ensure t
  :bind
  ("M-j" . avy-goto-char-timer)
  ("M-n" . avy-goto-line)
  ("C-t" . avy-goto-char-in-line))

(leaf avy-zap
  :doc "Zap to char using `avy'"
  :req "avy-0.2.0"
  :tag "extensions"
  :url "https://github.com/cute-jumper/avy-zap"
  :added "2022-09-26"
  :ensure t)

(leaf ace-window
  :doc "Quickly switch windows."
  :req "avy-0.5.0"
  :tag "location" "window"
  :url "https://github.com/abo-abo/ace-window"
  :added "2022-09-26"
  :ensure t
  :bind
  ("C-o" . ace-window)
  :custom
  (aw-keys . '(?j ?k ?l ?i ?o ?h ?y ?u ?p))
  :custom-face
  (aw-leading-char-face . '((t (:height 3.6 :foreground "#f1fa8c")))))

(leaf quickrun
  :doc "Run commands quickly"
  :req "emacs-26.1" "ht-2.0"
  :tag "tools" "emacs>=26.1"
  :url "https://github.com/emacsorphanage/quickrun"
  :added "2023-01-05"
  :emacs>= 26.1
  :ensure t)

(leaf autoinsert
  :doc "automatic mode-dependent insertion of text into new files"
  :tag "builtin"
  :added "2023-04-05"
  :defun yas/expand-snippet
  :defvar auto-insert-query auto-insert-directory
  :preface
  (defun my/fold-nomacros ()
    (interactive)
    (let* ((pos (point)))
      (goto-char (point-min))
      (re-search-forward "NOMACROS" nil t)
      (ts-fold-close)
      (goto-char (point-min))
      (goto-char pos)))
  (defun autoinsert-yas-expand nil
    "Replace text in yasnippet template."
    (yas/expand-snippet
     (buffer-string)
     (point-min)
     (point-max))
    (my/fold-nomacros))
  :when (auto-insert-mode)
  :setq ((auto-insert-query))
  :config
  (setf auto-insert-directory "~/.emacs.d/templates/")
  (define-auto-insert "/atcoder/.*\\.cpp\\'"
    ["cpp-atcoder.template" autoinsert-yas-expand]))

(leaf fringe-helper
  :doc "helper functions for fringe bitmaps"
  :tag "lisp"
  :url "http://nschum.de/src/emacs/fringe-helper/"
  :added "2023-07-23"
  :ensure t)

(leaf ts-fold
  :tag "out-of-MELPA"
  :added "2023-07-22"
  :el-get emacs-tree-sitter/ts-fold
  :require t
  :hook
  (tree-sitter-after-on-hook . ts-fold-indicators-mode))

;; Re-enable magic file name
(setq file-name-handler-alist my-saved-file-name-handler-alist)

(provide 'init)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
