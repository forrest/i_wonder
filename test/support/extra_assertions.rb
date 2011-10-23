# this is a little helpful assertion I like

def assert_include(collection, element, message = "")
  full_message = build_message(message, "<?> expected to be included in \n<?>.", 
                               element, collection)
  assert_block(full_message) { collection.include?(element) }
end