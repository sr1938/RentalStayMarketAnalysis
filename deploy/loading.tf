
# ####------------------------GLUE DATA-CATALOG & CRAWLER-------------------------------------------####

# defining database
resource "aws_glue_catalog_database" "RentalMarket" {
    name = "rental_market_database"
}

resource "aws_glue_classifier" "csv_classifier" {
  name          = "CustomCSVClassifier"
  
  csv_classifier {
    allow_single_column    = false
    contains_header        = "UNKNOWN"  # Automatic detection of headers
    delimiter              = ","
    disable_value_trimming = false
    quote_symbol           = "'"
  }
}


resource "aws_glue_crawler" "rental_market_analysis" {
    name = "rental_market_analysis_crawler"
    role = "arn:aws:iam::199657276973:role/LabRole"
    database_name = aws_glue_catalog_database.RentalMarket.name

    s3_target {
      path = "s3://group4-enrich-data-zone/final_enriched_data.csv"
    }
    tags = {
        product_type = "rental_market_analysis"
    }
    classifiers = [aws_glue_classifier.csv_classifier.name]

    # Enable schema inference
    schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DEPRECATE_IN_DATABASE"
  }
}

####-------------------------------- Athena ------------------------------------------####
resource "aws_athena_workgroup" "rental_market_analysis_workgroup" {
  name = "rental_market_analysis_workgroup"
  force_destroy = true

configuration {
    result_configuration {
        output_location = "s3://group4-enrich-data-zone/queryresults"
    }

  }
}
