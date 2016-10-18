;;; packages.el --- graphviz layer packages file for Spacemacs.
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
;; added to `graphviz-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `graphviz/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `graphviz/pre-init-PACKAGE' and/or
;;   `graphviz/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst sweatlake-lang-packages
  '(graphviz-dot-mode))

(defun sweatlake-lang/init-graphviz-dot-mode ()
  (use-package graphviz-dot-mode
    :mode "\\.dot$"
    :defer t
    :config
    (progn
      (spacemacs|add-toggle graphviz-live-reload
        :status graphviz-dot-auto-preview-on-save
        :on (graphviz-turn-on-live-preview)
        :off (graphviz-turn-off-live-preview)
        :documentation "Enable Graphviz live reload.")
      (define-key graphviz-dot-mode-map (kbd "M-q") 'graphviz-dot-indent-graph)
      (spacemacs/set-leader-keys-for-major-mode 'graphviz-dot-mode
        "t" 'spacemacs/toggle-graphviz-live-reload
        "c" 'compile
        "p" 'graphviz-dot-preview
        "," 'graphviz-dot-preview))))

;;; packages.el ends here
