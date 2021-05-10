curl --compressed -s https://cf-stream.tecartabible.com/8/products-list/PLAY_TecartaBible.json > assets/products.json
cp ../volumes/9/deploy/9.sqlite assets/9.sqlite
mkdir zip
cp -r ../volumes/9/deploy/9 zip
zip -r 9.zip -r zip
mv 9.zip assets/9.zip
rm -r zip
