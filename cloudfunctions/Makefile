upload:
	zip -R cloudfunctions.zip go.mod go.sum '*.go'
	gsutil cp cloudfunctions.zip gs://prototype-luke-asset-inventory/cloudfunctions.zip
	rm cloudfunctions.zip
