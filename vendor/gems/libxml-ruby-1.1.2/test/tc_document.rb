require "xml"
require 'test/unit'


class TestDocument < Test::Unit::TestCase
  def setup
    xp = XML::Parser.string('<ruby_array uga="booga" foo="bar"><fixnum>one</fixnum><fixnum>two</fixnum></ruby_array>')
    assert_instance_of(XML::Parser, xp)
    @doc = xp.parse
    assert_instance_of(XML::Document, @doc)
  end

  def teardown
    @doc = nil
  end

  def test_klass
    assert_instance_of(XML::Document, @doc)
  end

  def test_context
    context = @doc.context
    assert_instance_of(XML::XPath::Context, context)
  end

  def test_find
    set = @doc.find('/ruby_array/fixnum')
    assert_instance_of(XML::XPath::Object, set)
    assert_raise(NoMethodError) {
      xpt = set.xpath
    }
  end

  def test_ruby_xml_document_compression
    if XML.enabled_zlib?
      0.upto(9) do |i|
        assert_equal(i, @doc.compression = i)
        assert_equal(i, @doc.compression)
      end

      9.downto(0) do |i|
        assert_equal(i, @doc.compression = i)
        assert_equal(i, @doc.compression)
      end

      10.upto(20) do |i|
        # assert_equal(9, @doc.compression = i)
        assert_equal(i, @doc.compression = i) # This works around a bug in Ruby 1.8
        assert_equal(9, @doc.compression)
      end

      -1.downto(-10) do |i|
        # assert_equal(0, @doc.compression = i)
        assert_equal(i, @doc.compression = i) # FIXME This bug should get fixed ASAP
        assert_equal(0, @doc.compression)
      end
    end
  end

  def test_version
    assert_equal('1.0', @doc.version)

    doc = XML::Document.new('6.9')
    assert_equal('6.9', doc.version)
  end

  def test_write_root
    @doc.root = XML::Node.new('rubynet')
    assert_instance_of(XML::Node, @doc.root)
    assert_instance_of(XML::Document, @doc.root.doc)
    assert_equal("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rubynet/>\n",
                 @doc.to_s(:indent => false))
  end

  def test_encoding
    doc = XML::Document.new
    assert_equal(XML::Encoding::NONE, doc.encoding)

    file = File.expand_path(File.join(File.dirname(__FILE__), 'model/bands.xml'))
    doc = XML::Document.file(file)
    assert_equal(XML::Encoding::UTF_8, doc.encoding)

    doc.encoding = XML::Encoding::ISO_8859_1
    assert_equal(XML::Encoding::ISO_8859_1, doc.encoding)
  end

  def test_doc_node_type
    assert_equal XML::Node::DOCUMENT_NODE, XML::Document.new.node_type
  end

  def test_doc_node_type_name
    assert_equal 'document_xml', XML::Document.new.node_type_name
  end

  def test_xhtml
		doc = XML::Document.new
		assert ! doc.xhtml?
    xhtml_dtd = XML::Dtd.new "-//W3C//DTD XHTML 1.0 Transitional//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd", nil, doc, true
		assert doc.xhtml?
	end
  
end
