ARTICLE_DIR=articles/virtue-ethics-and-the-good-life

.PHONY: virtue-data virtue-python virtue-r clean

virtue-data:
	python3 $(ARTICLE_DIR)/python/generate_synthetic_virtue_data.py

virtue-python: virtue-data
	python3 $(ARTICLE_DIR)/python/virtue_panel_model.py
	python3 $(ARTICLE_DIR)/python/virtue_network_analysis.py
	python3 $(ARTICLE_DIR)/python/virtue_sensitivity_analysis.py

virtue-r: virtue-data
	Rscript $(ARTICLE_DIR)/r/virtue_flourishing_model.R

clean:
	find $(ARTICLE_DIR)/outputs -type f ! -name 'README.md' ! -name '.gitkeep' -delete
