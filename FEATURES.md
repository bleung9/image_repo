# Description of this app

This image repo allows anyone to submit an image via a standard POST request to be saved to the database. There is one table in the database called Image. Each uploaded image is an individual record, which stores various characteristics of that image (image, extension, width, height, text, idhash).

Upon submission, the following will happen:

1) The extension, width and height of the image are extracted using MiniMagick and saved to database.
2) The text is extracted with OCR using the [RTesseract gem](https://github.com/dannnylo/rtesseract). When the text is saved to the database, [Elasticsearch Rails](https://github.com/elastic/elasticsearch-rails) will automatically add the text for this image as field in a document to the index for text queries.
3) A unique [IDHash](https://github.com/Nakilon/dhash-vips) for each image is generated upon submission and saved. This is required for the image similarity filter, which allows users to submit an image, and search for all images that look similar to their submission. Two images are considered similar if their [Hamming distance](https://en.wikipedia.org/wiki/Hamming_distance) is below the threshold of 25. For more details, the [gem I used](https://github.com/Nakilon/dhash-vips) is dhash-vips. More details on dHashing can be found [here](https://www.hackerfactor.com/blog/index.php?/archives/529-Kind-of-Like-That.html).

Users can filter existing images in the database for height, width, extension, and text. The app will handle multiple parameters. For text search, you can enter multiple words separated by spaces (Elasticsearch tokenizes search strings with its standard tokenizer). This will return all images that contain any of those words. However, note that for optimal OCR results, images with white backgrounds and well contrasted text will work best.

Image similarity search is completely separate from the previous filters. _Two sample images are included in `/public/sample_similar_images`._ Simply upload one to the database, and submit the other in the image similarity filter. If you want to test this further, you can also take two of your own selfies or pictures.

Note that because this is a backend position I'm applying for, the interface is quite barebones.

## Future improvements

#### Background job processing

In production, image submission, OCR, Elasticsearch indexing and image hashing must be done in a background job server. OCR and image hashing are expensive computations, and this is reflected in the length of time it takes to run my test suite of just 18 examples (to be discussed later). This would be similar to what Google Drive does, where users can continue browsing their drive while files are being uploaded in the background.

#### Inefficient search for image similarity

This app computes the Hamming distance against every image in the database. Of course, this is linear time and inefficient. Unfortunately, this is not something which can be done more efficiently with a SQL query. There is actually a [Stack Overflow answer on this](https://stackoverflow.com/questions/9606492/hamming-distance-similarity-searches-in-a-database/47487949#47487949), with links to papers on the topic, and an improvement on my implementation would probably involve something like that.

#### Speeding up tests

The test suite of 18 examples right now take a long time to run. All of them actually call all the gems that were previously mentioned. An alternate approach is to stub those responses to speed up the tests, and write separate tests for the functionality of each of those gems. These can be run whenever a gem is updated or the version has changed to ensure that no behavior has unexpectedly changed.

#### Deleting and updating images

Basic POST requests for updating and deleting images would've also been trivial to add to this project, and easy to integrate with Elasticsearch (deleting or updating an index when an image is deleted or updated).

