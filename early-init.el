;;; early-init.el --- Early Initialization. -*- lexical-binding: t; no-byte-compile: t -*-
;;; Commentary:
;;
;; Emacs 27+ introduces early-init.el, which is run before init.el,
;; before package and UI initialization happens.
;;
;;; Code:

;; 参考: https://qiita.com/minoruGH/items/ae9e5faf7265d54c4cbd

;; Defer garbage collection further back in the startup process
(setq gc-cons-threshold (* 128 1024 1024))

;; For slightly faster startup
(setq package-enable-at-startup nil)

;; Always load newest byte code
(setq load-prefer-newer t)

;; Inhibit resizing frame
(setq frame-inhibit-implied-resize t)

;; Faster to disable these here (before they've been initialized)
;; (push '(fullscreen . maximized) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Suppress flashing at startup
;; (setq inhibit-redisplay t)
;; (setq inhibit-message t)
;; (add-hook 'emacs-startup-hook
;;           (lambda ()
;;             (setq inhibit-redisplay nil)
;; 			(setq inhibit-message nil)
;; 			(redisplay)))

;; Startup setting
;; (setq inhibit-splash-screen t)
;; (setq inhibit-startup-message t)
;; (setq byte-compile-warnings '(cl-functions))
;; (custom-set-faces '(default ((t (:background "#282a36")))))


(provide 'early-init)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; early-init.el ends here
