# Little helpful assertions I like

def assert_include(collection, element, message = "")
  full_message = build_message(message, "<?> expected to be included in \n<?>.", 
                               element, collection)
  assert_block(full_message) { collection.include?(element) }
end

def assert_valid(record, message = "")
  record.valid?
  full_message = build_message(message, 
      "? expected to be valid, but has the following errors: \n ?.", 
     record, record.errors.full_messages.join("\n"))
  assert_block(full_message) { record.valid? }
end