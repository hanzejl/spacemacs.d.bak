;;; packages.el --- magic-org layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: zr <zr@zrdeMacBook-Pro.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `sweatlake-org-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `sweatlake-org/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `sweatlake-org/pre-init-PACKAGE' and/or
;;   `sweatlake-org/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst sweatlake-org-packages
  '((org :location built-in)
    org-pomodoro
    hexo
    ))


(defun sweatlake-org/init-hexo ()
  (use-package hexo
    :config (progn
              (setq hexo-new-format 'org)
              (spacemacs/set-leader-keys "abh" 'sweatlake/hexo-relume-me)
              )
    ))


(defun sweatlake-org/post-init-org-pomodoro ()
  (use-package org-pomodoro
    :config (progn
              (spacemacs/set-leader-keys-for-major-mode 'org-mode
                "p" 'org-pomodoro)
              (spacemacs/set-leader-keys-for-major-mode 'org-agenda-mode
                "p" 'org-pomodoro)
              (setq
               org-pomodoro-format "§·%s"
               org-pomodoro-short-break-format "♨·%s"
               org-pomodoro-long-break-format "❆·%s")

              (add-hook 'org-pomodoro-finished-hook
                        (lambda ()
                          (sweatlake/terminal-notify-osx "Pomodoro Finished"
                                                         "Have a break!")))
              (add-hook 'org-pomodoro-short-break-finished-hook
                        (lambda ()
                          (sweatlake/terminal-notify-osx "Short Break"
                                                         "Ready to Go?")))
              (add-hook 'org-pomodoro-long-break-finished-hook
                        (lambda ()
                          (sweatlake/terminal-notify-osx "Long Break"
                                                         "Ready to Go?")))
              (add-hook 'org-pomodoro-killed-hook
                        (lambda () (sweatlake/terminal-notify-osx
                                    "Pomodoro Killed"
                                    "One does not simply kill a pomodoro!")))
      )))

(defun sweatlake-org/post-init-org()
  (add-hook 'org-mode-hook 'turn-on-auto-fill)

  (with-eval-after-load 'org
    (progn
      (setq-default
       org-html-validation-link nil
       ;; some variables about the startup
       org-startup-with-inline-images nil       ; not show the inline images
       org-agenda-start-on-weekday nil          ; start on weekday none
       org-agenda-span 14                       ; set the org-days from now
       org-agenda-window-setup 'current-window  ; current-window to open the agenda view
       org-startup-indented t
       org-log-into-drawer t

       org-export-with-priority t

       org-agenda-files '("~/work/Dropbox/vitae/gtd/")
       ;; variables about the org-capture directory
       org-capture-directory "~/work/Dropbox/vitae/capture/"
       org-default-notes-files (concat org-capture-directory "/todo.org")
       org-html-htmlize-output-type 'css
       )

      (defadvice org-html-paragraph (before org-html-paragraph-advice
                                            (paragraph contents info) activate)
        "Join consecutive Chinese lines into a single long "
        "line without unwanted space when exporting org-mode to html."
        (let* ((origin-contents (ad-get-arg 1))
               (fix-regexp "[[:multibyte:]]")
               (fixed-contents
                (replace-regexp-in-string
                 (concat
                  "\\(" fix-regexp "\\) *\n *\\(" fix-regexp "\\)") "\\1\\2"
                  origin-contents)))
          (ad-set-arg 1 fixed-contents)))

      ;; variables about the TODO Keywords
      (setq-default
       org-todo-keywords
       (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
               (sequence "WAITING(w@/!)" "HOLD(h@/!)"
                         "PROJECT(p@)" "|" "CANCELLED(c@/!)" "|" "CLOSED(s@/!)"
                         "PHONE" "METTING")))

       org-todo-keyword-faces
       (quote (("TODO" :foreground "red" :weight bold)
               ("NEXT" :foreground "blue" :weight bold)
               ("DONE" :foreground "forest green" :weight bold)
               ("WAITING" :foreground "orange" :weight bold)
               ("HOLD" :foreground "magenta" :weight bold)
               ("CANCELLED" :foreground "forest green" :weight bold)
               ("CLOSED" :foreground "forest green" :weight bold)
               ("MEETING" :foreground "forest green" :weight bold)
               ("PHONE" :foreground "forest green" :weight bold)))

       org-todo-state-tags-triggers
       (quote (("CANCELLED" ("CANCELLED" . t))
               ("WAITING" ("WAITING" . t))
               ("CLOSED" ("CLOSED" . t))
               ("HOLD" ("WAITING") ("HOLD" . t))
               ("DONE" ("WAITING") ("HOLD"))
               ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
               ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
               ("DONE" ("WAITING") ("CANCELLED") ("HOLD"))))
       )

      ;; variables about the org-priority
      ;; see the "Put First Things First"
      ;; -- A is for Urgent and Important
      ;; -- B is for Not Urgent but Important
      ;; -- C is for not Urgent and not Important
      ;; -- D is for Urgent but Not Important
      (setq-default
       org-highest-priority ?A
       org-lowest-priority ?D
       org-default-priority ?B
       org-priority-faces (quote ((?A . (:foreground "#FF00FF" :weight bold))
                                  (?B . (:foreground "green" :weight bold))
                                  (?C . (:foreground "#00CCFF"))
                                  (?D . (:foreground "#9900FF"))
                                  )))

      (setq-default
       ;; capture templates
       org-capture-templates
       (quote (("t" "Todo" entry (file+headline (concat org-capture-directory "/todo.org") "Plans")
                "* TODO %?\n%U\n" :clock-in t :clock-resume t)
               ("m" "Meeting" entry (file+headline (concat org-capture-directory "/todo.org") "Meetings")
                "* MEETING with %? :MEETING:\n%U\n" :clock-in t :clock-resume t)
               ("p" "Phone call" entry (file+headline (concat org-capture-directory "/todo.org") "Phone Call")
                "* PHONE %? :PHONE:\n%U\n" :clock-in t :clock-resume t)

               ("b" "Books" item (file+headline (concat org-capture-directory "/todo.org") "Books")
                "- 需要阅读《%?》    %U\n")
               ("f" "Films" item (file+headline (concat org-capture-directory "/todo.org") "Films")
                "- 优秀电影、纪录片《%?》    %U\n")
               ("j" "Jounery" entry (file+headline (concat org-capture-directory "/todo.org") "Jounery")
                "** 计划去<%?>地方旅行\nSCHEDULED: %u\n")
               ("e" "Entertainment" entry (file+headline (concat org-capture-directory "/todo.org") "Entertainment")
                "** <%?>: %u")

               ;; note file
               ("n" "Note" entry (file (concat org-capture-directory "/note.org"))
                "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)

               ;; diary file
               ("d" "Diary" entry (file+datetree (concat org-capture-directory "/diary.org"))
                "* %?\n%U\n" :clock-in t :clock-resume t)
               )))

      (setq org-plantuml-jar-path
            (expand-file-name "~/.spacemacs.d/plantuml.jar"))
      (setq org-ditaa-jar-path "~/.spacemacs.d/ditaa.jar")
      (setq-default org-babel-results-keyword "results")

      (org-babel-do-load-languages
       'org-babel-load-languages
       '((perl . t)
         (ruby . t)
         (sh . t)
         (dot . t)
         (js . t)
         (latex .t)
         (python . t)
         (emacs-lisp . t)
         (plantuml . t)
         (C . t)
         (ditaa . t)))

      (setq org-confirm-babel-evaluate nil)
      (add-to-list 'org-src-lang-modes (quote ("dot" . graphviz-dot)))

      ;; org-mode 設定
      (require 'org-crypt)

      ;; 當被加密的部份要存入硬碟時，自動加密回去
      (org-crypt-use-before-save-magic)

      ;; 設定要加密的 tag 標籤為 secret
      (setq org-crypt-tag-matcher "secret")

      ;; 避免 secret 這個 tag 被子項目繼承 造成重複加密
      ;; (但是子項目還是會被加密喔)
      (setq org-tags-exclude-from-inheritance (quote ("secret")))

      ;; 用於加密的 GPG 金鑰
      ;; 可以設定任何 ID 或是設成 nil 來使用對稱式加密 (symmetric encryption)
      (setq org-crypt-key nil)
      )))

;;; packages.el ends here
