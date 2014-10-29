# Loads the schema into the in-memory database.
schema_loader = -> { load Rails.root.join("db", "schema.rb") }

# Without this it will spit out the output of the schema load at the
# start of every test run.
silence_stream(STDOUT, &schema_loader)
