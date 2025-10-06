# DUToolkit 1.0.0

* Initial CRAN submission.

# DUToolkit 1.0.1

## Bug fixes and maintenance

- Updated tests for compatibility with **ggplot2 (>= 3.5.0)**.  
  `ggplot` objects now include additional S7 class labels, which caused strict class
  checks to fail. Tests were updated to confirm inheritance from `"ggplot"` (or `"gg"`)
  instead of requiring an exact class vector.    

- No changes to package functionality; this release is for CRAN compatibility only.

# DUToolkit 1.0.2

## Bug fixes and maintenance

- Added reference to Wiggins et al. (2025) <https://doi.org/10.1371/journal.pone.0332522>
  in the package Description, README, and vignettes to document the underlying
  methodology and related publication.

- No changes to package functionality; this release updates package
  documentation only.
