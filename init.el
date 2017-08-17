;;; init.el ---

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

(setq package-user-dir "~/.emacs.d/elpa")

(package-initialize)

(add-to-list 'exec-path "/usr/local/bin")

;; UI

(defun switch-theme (name)
  (interactive
   (list
    (intern (completing-read "Load custom theme: "
                             (mapcar 'symbol-name (custom-available-themes))))))
  (mapc #'disable-theme custom-enabled-themes)
  (customize-save-variable
   `custom-enabled-themes (list name)))

(when (window-system)
  (x-focus-frame nil)
  (let ((font-name "Menlo-12"))
    (when (find-font (font-spec :name font-name))
      (set-frame-font font-name))))

;; cleaner look
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; disable startup screen and *scratch* message
(setq inhibit-startup-screen t
      initial-scratch-message nil)

;; smooth like an andel scrolling
(setq scroll-margin 0
      scroll-conservatively 100000000
      scroll-preserve-screen-position 1)

(setq mouse-wheel-scroll-amount '(2 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time

;; hide mouse cursor
(mouse-avoidance-mode 'cat-and-mouse)

(global-linum-mode 0) ;; remove gutter
(blink-cursor-mode -1) ;; remove blinking

(setq ns-use-srgb-colorspace nil)

(require 'powerline)
(powerline-default-theme)

;; mode line
(line-number-mode t)
(column-number-mode t)
(display-time-mode t)

;; theme
(use-package zenburn-theme)
(load-theme 'zenburn t)


;; Editor configuration

(setq-default indent-tabs-mode nil  ;; don't use tabs to indent
              tab-width 4           ;; but maintain correct appearance
              case-fold-search t    ;; case INsensitive search
              default-directory "~"
              fill-column 80)

;; All things UTF-8.
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; delete the selection with a keypress
(delete-selection-mode t)

;; take care of the whitespace
(require 'whitespace)
(setq whitespace-style '(face trailing lines-tail
                              space-before-tab
                              indentation space-after-tab)
      whitespace-line-column 1200)

(defun turn-on-whitespace ()
  (whitespace-mode t)
  (add-hook 'before-save-hook 'delete-trailing-whitespace))

(add-hook 'prog-mode-hook 'turn-on-whitespace)

(setq next-line-add-newlines nil  ;; don't add new lines when scrolling down
      require-final-newline t     ;; end files with a newline
      mouse-yank-at-point t       ;; yank at cursor, NOT at mouse position
      kill-whole-line t)

;; whenever an external process changes a file underneath emacs, and there
;; was no unsaved changes in the corresponding buffer, just revert its
;; content to reflect what's on-disk.
(global-auto-revert-mode t)

;; meaningful names for buffers with the same name
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward
      uniquify-separator ":"
      uniquify-after-kill-buffer-p t     ;; rename after killing uniquified
      uniquify-ignore-buffers-re "^\\*") ;; don't muck with special buffers

;; use shift + arrow keys to switch between visible buffers
(require 'windmove)
(windmove-default-keybindings)
(setq windmove-wrap-around t)

;; diminish keeps the modeline tidy
(require 'diminish)

;; some parens love
(use-package smartparens-config
  :ensure smartparens
  :defer t
  :init (progn
          (show-smartparens-global-mode)
          (set-face-foreground 'show-paren-match "white")))

(use-package rainbow-delimiters
  :ensure t
  :config (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(add-hook 'prog-mode-hook 'turn-on-smartparens-mode)

(autoload 'enable-paredit-mode "paredit"
  "Turn on pseudo-structural editing of Lisp code."
  t)
(add-hook 'emacs-lisp-mode-hook       'enable-paredit-mode)
(add-hook 'lisp-mode-hook             'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
(add-hook 'scheme-mode-hook           'enable-paredit-mode)
(add-hook 'clojure-mode-hook          'enable-paredit-mode)

;; highlight the current line
(global-hl-line-mode +1)

(use-package helm
  :ensure t
  :init
  (progn
    (require 'helm-config)
    (setq helm-split-window-in-side-p t
          helm-M-x-fuzzy-match t
          helm-buffers-fuzzy-matching t
          helm-recentf-fuzzy-match t
          helm-move-to-line-cycle-in-source t
          helm-ff-search-library-in-sexp t
          helm-ff-file-name-history-use-recentf t
          helm-echo-input-in-header-line t)
    ;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
    ;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
    ;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
    ;; (c) Emacs Prelude
    (global-set-key (kbd "C-c h") 'helm-command-prefix)
    (global-unset-key (kbd "C-x c"))

    (helm-mode))
  :diminish helm-mode
  :bind (("C-c h" . helm-mini)
         ("C-c i" . helm-imenu)
         ("C-h a" . helm-apropos)
         ("C-x f" . helm-recentf)
         ("C-x b" . helm-for-files)
         ("C-x C-b" . helm-buffers-list)
         ("C-x C-f" . helm-find-files)
         ("M-y" . helm-show-kill-ring)
         ("M-x" . helm-M-x)))

(require 'projectile)
(use-package projectile
  :ensure t
  :init
  (progn
    (setq projectile-completion-system 'helm
          projectile-create-missing-test-files t
          projectile-switch-project-action #'projectile-commander)
    (projectile-global-mode))
  :diminish projectile-mode)

;; helm for project navigation
(require 'helm-projectile)
(use-package helm-projectile
  :ensure t
  :init (progn
          (helm-projectile-on)
          (setq helm-for-files-preferred-list
                '(helm-source-buffers-list
                  helm-source-projectile-files-list
                  helm-source-recentf
                  helm-source-bookmarks
                  helm-source-file-cache
                  helm-source-files-in-current-dir
                  helm-source-locate))))

;; sensible undo
(use-package undo-tree
  :ensure t
  :commands undo-tree-visualize
  :bind ("C-S-z" . undo-tree-redo)
  :config (progn
            (global-undo-tree-mode)
            (setq undo-tree-visualizer-timestamps t
                  undo-tree-visualizer-diff t
                  undo-tree-auto-save-history t)

            (defadvice undo-tree-make-history-save-file-name
                (after undo-tree activate)
              (setq ad-return-value (concat ad-return-value ".gz")))

            (custom-set-variables
             '(undo-tree-history-directory-alist
               (quote (("." . "~/.emacs.d/undo/"))))))
  :diminish undo-tree-mode)

;; my git
(use-package magit
  :ensure t
  :commands magit-status
  :bind ("C-c g" . magit-status)
  :config (progn
            (setq async-bytecomp-allowed-packages nil)

            (use-package magithub
              :ensure t)))

(use-package git-timemachine
  :ensure t
  :defer t
  :commands git-timemachine)

;; git gutter
(global-git-gutter-mode +1)

;; incremental searching
(use-package anzu
  :ensure t
  :diminish anzu-mode
  :init (global-anzu-mode +1))

;; view large files easily
(use-package vlf-setup
  :ensure vlf
  :defer t
  :commands vlf)

(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))


;;; Languages

;; Clojure

(use-package clojure-mode
  :ensure t)

(use-package cider)
(require 'cider)

;; Python

(use-package python-mode
  :ensure t
  :mode ("\\.py\\'" . python-mode)
  :commands python-mode
  :config (progn
            (add-hook 'python-mode-hook (lambda () (run-hooks 'prog-mode-hook)))
            (add-hook 'python-mode-hook
                      (lambda ()
                        ;; See https://github.com/company-mode/company-mode/issues/105
                        ;; for details on this nasty bug.
                        (remove-hook 'completion-at-point-functions
                                     'py-shell-complete t)
                        (subword-mode +1)
                        (electric-indent-mode -1)

                        (setq-local eldoc-documentation-function nil)))))

;; C, C++

(use-package cc-mode
  :init (add-hook 'c-mode-common-hook
                  '(lambda ()
                     (local-set-key (kbd "RET") 'newline-and-indent)
                     (setq c-default-style "linux"
                           c-basic-offset 4)
                     (c-set-offset 'substatement-open 0))))

(use-package cmake-mode
  :ensure t
  :defer t)

;; Markdown

(use-package markdown-mode
  :ensure t
  :commands markdown-mode
  :mode "\\.md\\|\\.markdown")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   (vector "#ffffff" "#f36c60" "#8bc34a" "#fff59d" "#4dd0e1" "#b39ddb" "#81d4fa" "#263238"))
 '(ansi-term-color-vector
   [unspecified "#263238" "#f07178" "#c3e88d" "#ffcb6b" "#82aaff" "#c792ea" "#82aaff" "#eeffff"])
 '(custom-enabled-themes (quote (zenburn)))
 '(custom-safe-themes
   (quote
    ("25c06a000382b6239999582dfa2b81cc0649f3897b394a75ad5a670329600b45" "87d46d0ad89557c616d04bef34afd191234992c4eb955ff3c60c6aa3afc2e5cc" "5a7830712d709a4fc128a7998b7fa963f37e960fd2e8aa75c76f692b36e6cf3c" "527df6ab42b54d2e5f4eec8b091bd79b2fa9a1da38f5addd297d1c91aa19b616" "80930c775cef2a97f2305bae6737a1c736079fdcc62a6fdf7b55de669fbbcd13" "d9dab332207600e49400d798ed05f38372ec32132b3f7d2ba697e59088021555" "93268bf5365f22c685550a3cbb8c687a1211e827edc76ce7be3c4bd764054bad" "760ce657e710a77bcf6df51d97e51aae2ee7db1fba21bbad07aab0fa0f42f834" "1d079355c721b517fdc9891f0fda927fe3f87288f2e6cc3b8566655a64ca5453" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "5dc0ae2d193460de979a463b907b4b2c6d2c9c4657b2e9e66b8898d2592e3de5" "98cc377af705c0f2133bb6d340bf0becd08944a588804ee655809da5d8140de6" "446cc97923e30dec43f10573ac085e384975d8a0c55159464ea6ef001f4a16ba" "350dc341799fbbb81e59d1e6fff2b2c8772d7000e352a5c070aa4317127eee94" "196df8815910c1a3422b5f7c1f45a72edfa851f6a1d672b7b727d9551bb7c7ba" "c968804189e0fc963c641f5c9ad64bca431d41af2fb7e1d01a2a6666376f819c" "1263771faf6967879c3ab8b577c6c31020222ac6d3bac31f331a74275385a452" "b3bcf1b12ef2a7606c7697d71b934ca0bdd495d52f901e73ce008c4c9825a3aa" default)))
 '(fci-rule-color "#383838")
 '(hl-sexp-background-color "#1c1f26")
 '(markdown-command "/usr/local/bin/pandoc")
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(package-selected-packages
   (quote
    (base16-theme material-theme powerline zenburn-theme vlf use-package undo-tree smartparens smart-mode-line rainbow-mode rainbow-delimiters python-mode paredit markdown-mode magit helm-projectile git-timemachine git-gutter cmake-mode cider anzu)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   (quote
    ((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))

;; HTML, CSS

(add-hook 'sgml-mode-hook (lambda () (setq tab-width 2)))

(use-package rainbow-mode
  :ensure t
  :defer t
  :diminish rainbow-mode
  :config (progn
            (add-hook 'html-mode-hook 'rainbow-turn-on)
            (add-hook 'css-mode-hook 'rainbow-turn-on)))

(use-package smartparens
  :ensure t
  :init (sp-with-modes '(html-mode sgml-mode)
          (sp-local-pair "<" ">")))

;;; init.el ends here

;; Thanks super-bobry, matklad and bbatsov
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
