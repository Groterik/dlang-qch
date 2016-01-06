# About
Qt Compressed Help (.qch) generator tools for D library reference.

# Create .qch file
1. Generate htmls docs using .sh script: ```bash generate_html.sh -d <phobos-dir> -o <output-html-dir>```
1. Generate .qhp file using .d script: ```rdmd generate_qhp.d -i <html-dir> -o <output-qhp-path>```
1. Create .qch file using Qt Help Generator: ```qhelpgenerator <qhp-path> -o <qch-path>```

# Using .qch file in Qt Creator
Just go to ```Options -> Help -> Documentation``` and add the generated .qch file in order to enable the documentation in ```Help mode```.

