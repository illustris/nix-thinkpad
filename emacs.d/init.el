;; Set keybindings for cycling buffers
(global-set-key [C-prior] 'previous-buffer)
(global-set-key [C-next] 'next-buffer)

(setq mouse-yank-at-point t)

(setq load-prefer-newer t)

(setq-default c-basic-offset 8
	tab-width 8
	indent-tabs-mode t)

(global-set-key (kbd "C-x k") 'kill-this-buffer)
(put 'scroll-left 'disabled nil)

(setq inhibit-startup-screen t)

(load-theme 'cobalt t t)
(enable-theme 'cobalt)

(defun toggle-indentation ()
	"Toggle between tabs and spaces for indentation."
	(interactive)
	(if indent-tabs-mode
		(progn
			(setq-local indent-tabs-mode nil)
			(setq-local tab-width 2)
		)
		(progn
			(setq-local indent-tabs-mode t)
			(setq-local tab-width 8)
		)
	)
	(message "Indentation set to: %s" (if indent-tabs-mode "tabs" "spaces"))
)

(eval-after-load 'nix-mode
	(add-hook 'nix-mode-hook
		(lambda ()
			(define-key nix-mode-map (kbd "<f8>") 'toggle-indentation)
			(setq-local indent-tabs-mode t)
			(setq-local tab-width 8)
		)
	)
)

