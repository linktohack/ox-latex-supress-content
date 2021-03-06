(require 'ox)

(defun link/org-export-suppress-content (backend)
  "Filter to remove headline (or content) with `noexport', `nocontent'
and `noheading' tag"
  (outline-show-all)
  (org-map-entries
   #'(lambda ()
       (let ((beg (point)))
         (org-next-visible-heading 1)
         (backward-char)
         (delete-region beg (point))))
   "noexport")
  (org-map-entries
   #'(lambda ()
       (org-set-tags-to (cl-remove-if
                         #'(lambda (tag)
                             (string-equal "nocontent" tag))
                         (org-get-tags-at (point) t)))
       (beginning-of-line 2)
       (unless (org-at-heading-p)
         (while (or (org-at-property-p) (org-at-drawer-p) (org-at-planning-p))
           (beginning-of-line 2)))
       (unless (org-at-heading-p)
         (let ((beg (point)))
           (org-next-visible-heading 1)
           (backward-char)
           (delete-region beg (point)))))
   "nocontent")
  (org-map-entries
   #'(lambda ()
       (if (member "noheading" (org-get-tags-at (point) t))
           (delete-region (line-beginning-position) (line-end-position))
         (org-promote)))
   "noheading"))

(add-hook 'org-export-before-processing-hook #'link/org-export-suppress-content)

(provide 'ox-latex-suppress-content)
