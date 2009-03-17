require 'xml'
require 'stringio'
require 'test/unit'

class TestReader < Test::Unit::TestCase
  XML_FILE = File.join(File.dirname(__FILE__), 'model/atom.xml')

  def verify_simple(reader)
    node_types = []
    
    # Read each node
    26.times do
      assert(reader.read)
      node_types << reader.node_type
    end

    # There are no more nodes
    assert(!reader.read)

    # Check what was read
    expected = [XML::Reader::TYPE_PROCESSING_INSTRUCTION,
                XML::Reader::TYPE_ELEMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_COMMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_ELEMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_ELEMENT,
                XML::Reader::TYPE_CDATA,
                XML::Reader::TYPE_END_ELEMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_ELEMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_ELEMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_ELEMENT,
                XML::Reader::TYPE_TEXT,
                XML::Reader::TYPE_END_ELEMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_END_ELEMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_END_ELEMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_END_ELEMENT,
                XML::Reader::TYPE_SIGNIFICANT_WHITESPACE,
                XML::Reader::TYPE_END_ELEMENT]

    assert_equal(expected, node_types)
  end

  def test_document
    reader = XML::Reader.document(XML::Document.file(XML_FILE))
    verify_simple(reader)
  end

  def test_file
    reader = XML::Reader.file(XML_FILE)
    verify_simple(reader)
  end

  def test_invalid_file
    assert_raise(XML::Error) do
      XML::Reader.file('/does/not/exist')
    end
  end

  def test_string
    reader = XML::Reader.string(File.read(XML_FILE))
    verify_simple(reader)
  end

  def test_io
    File.open(XML_FILE, 'rb') do |io|
      reader = XML::Reader.io(io)
      verify_simple(reader)
    end
  end

  def test_io_gc
    # Test that the reader keeps a reference
    # to the io object
    file = File.open(XML_FILE, 'rb')
    reader = XML::Reader.io(file)
    file = nil
    GC.start
    assert(reader.read)
  end

  def test_string_io
    data = File.read(XML_FILE)
    string_io = StringIO.new(data)
    reader = XML::Reader.io(string_io)
    verify_simple(reader)
  end

  def test_error
    reader = XML::Reader.string('<foo blah')

    error = assert_raise(XML::Error) do
      reader.read
    end
    assert_equal("Fatal error: Couldn't find end of Start Tag foo at :1.", error.to_s)
  end

  def test_deprecated_error_handler
    called = false
    reader = XML::Reader.string('<foo blah')
    reader.set_error_handler do |error|
      called = true
    end

    assert_raise(XML::Error) do
      reader.read
    end

    assert(called)
  end

  def test_deprecated_reset_error_handler
    called = false
    reader = XML::Reader.string('<foo blah')
    reader.set_error_handler do |error|
      called = true
    end
    reader.reset_error_handler

    assert_raise(XML::Error) do
      reader.read
    end

    assert(!called)
  end

  def test_attr
    parser = XML::Reader.string("<foo x='1' y='2'/>")
    assert(parser.read)
    assert_equal('foo', parser.name)
    assert_equal('1', parser['x'])
    assert_equal('1', parser[0])
    assert_equal('2', parser['y'])
    assert_equal('2', parser[1])
    assert_equal(nil, parser['z'])
    assert_equal(nil, parser[2])
  end

  def test_value
    parser = XML::Reader.string("<foo><bar>1</bar><bar>2</bar><bar>3</bar></foo>")
    assert(parser.read)
    assert_equal('foo', parser.name)
    assert_equal(nil, parser.value)
    3.times do |i|
      assert(parser.read)
      assert_equal(XML::Reader::TYPE_ELEMENT, parser.node_type)
      assert_equal('bar', parser.name)
      assert(parser.read)
      assert_equal(XML::Reader::TYPE_TEXT, parser.node_type)
      assert_equal((i + 1).to_s, parser.value)
      assert(parser.read)
      assert_equal(XML::Reader::TYPE_END_ELEMENT, parser.node_type)
    end
  end

  def test_expand
    reader = XML::Reader.file(XML_FILE)
    reader.read
    node = reader.expand
    doc = node.doc
    reader.close
    GC.start

    doc.standalone?
  end

  def test_mode
    reader = XML::Reader.string('<xml/>')
    assert_equal(XML::Reader::MODE_INITIAL, reader.read_state)
    reader.read
    assert_equal(XML::Reader::MODE_EOF, reader.read_state)
  end

  def test_bytes_consumed
    reader = XML::Reader.file(XML_FILE)
    reader.read
    assert_equal(416, reader.byte_consumed)
  end

  def test_node
    XML.default_line_numbers = true
    reader = XML::Reader.file(XML_FILE)

    # first try to get a node
    assert_nil(reader.node)

    reader.read
    assert_instance_of(XML::Node, reader.node)
  end

  def test_base_uri
    # UTF8:
    # ö - c3 b6 in hex, \303\266 in octal
    # ü - c3 bc in hex, \303\274 in octal
    xml = "<bands genre=\"metal\">\n  <m\303\266tley_cr\303\274e country=\"us\">An American heavy metal band formed in Los Angeles, California in 1981.</m\303\266tley_cr\303\274e>\n  <iron_maiden country=\"uk\">British heavy metal band formed in 1975.</iron_maiden>\n</bands>"
    reader = XML::Reader.string(xml, :base_uri => "http://libxml.rubyforge.org")

    reader.read
    assert_equal(reader.base_uri, "http://libxml.rubyforge.org")
  end

  def test_options
    xml = <<-EOS
      <!DOCTYPE foo [<!ENTITY foo 'bar'>]>
      <test>
        <cdata><![CDATA[something]]></cdata>
        <entity>&foo;</entity>
      </test>
    EOS

    # Parse normally
    reader = XML::Reader.string(xml)
    reader.read # foo
    reader.read # test
    reader.read # text
    reader.read # cdata
    reader.read # cdata-section
    assert_equal(XML::Node::CDATA_SECTION_NODE, reader.node_type)

    # Convert cdata section to text
    reader = XML::Reader.string(xml, :options => XML::Parser::Options::NOCDATA)
    reader.read # foo
    reader.read # test
    reader.read # text
    reader.read # cdata
    reader.read # cdata-section
    assert_equal(XML::Node::TEXT_NODE, reader.node_type)
  end

  def test_encoding
    # ISO_8859_1:
    # ö - f6 in hex, \366 in octal
    # ü - fc in hex, \374 in octal
    xml = "<bands genre=\"metal\">\n  <m\366tley_cr\374e country=\"us\">An American heavy metal band formed in Los Angeles, California in 1981.</m\366tley_cr\374e>\n  <iron_maiden country=\"uk\">British heavy metal band formed in 1975.</iron_maiden>\n</bands>"

    reader = XML::Reader.string(xml, :encoding => XML::Encoding::ISO_8859_1)
    reader.read

    # libxml converts all data sources to utf8 internally
    assert_equal("<bands genre=\"metal\">\n  <m\303\266tley_cr\303\274e country=\"us\">An American heavy metal band formed in Los Angeles, California in 1981.</m\303\266tley_cr\303\274e>\n  <iron_maiden country=\"uk\">British heavy metal band formed in 1975.</iron_maiden>\n</bands>",
                     reader.read_outer_xml)
  end

  def test_invalid_encoding
    # ISO_8859_1:
    # ö - f6 in hex, \366 in octal
    # ü - fc in hex, \374 in octal
    xml = "<bands genre=\"metal\">\n  <m\366tley_cr\374e country=\"us\">An American heavy metal band formed in Los Angeles, California in 1981.</m\366tley_cr\374e>\n  <iron_maiden country=\"uk\">British heavy metal band formed in 1975.</iron_maiden>\n</bands>"

    reader = XML::Reader.string(xml)
    error = assert_raise(XML::Error) do
      node = reader.read
    end

    assert_equal("Fatal error: Input is not proper UTF-8, indicate encoding !\nBytes: 0xF6 0x74 0x6C 0x65 at :2.",
                 error.to_s)

  end

  def test_file_encoding
    reader = XML::Reader.file(XML_FILE)
    reader.read
    assert_equal(reader.encoding, XML::Encoding::UTF_8)
  end

  def test_string_encoding
    # ISO_8859_1:
    # ö - f6 in hex, \366 in octal
    # ü - fc in hex, \374 in octal
    xml = "<bands genre=\"metal\">\n  <m\366tley_cr\374e country=\"us\">An American heavy metal band formed in Los Angeles, California in 1981.</m\366tley_cr\374e>\n  <iron_maiden country=\"uk\">British heavy metal band formed in 1975.</iron_maiden>\n</bands>"
    reader = XML::Reader.string(xml, :encoding => XML::Encoding::ISO_8859_1)
    reader.read

    # Encoding is always null for strings, very annoying!
    assert_equal(reader.encoding, XML::Encoding::NONE)
  end
end