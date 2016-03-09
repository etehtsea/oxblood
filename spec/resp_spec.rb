require 'resp'

RSpec.describe RESP do
  describe '.serialize' do
    def serialize(body)
      described_class::serialize(body)
    end

    context 'Integer' do
      specify do
        expect(serialize(0)).to eq(":0\r\n")
      end

      specify do
        expect(serialize(1000)).to eq(":1000\r\n")
      end
    end

    context 'Bulk String' do
      specify do
        expect(serialize('')).to eq("$0\r\n\r\n")
      end

      specify do
        expect(serialize(nil)).to eq("$-1\r\n")
      end

      specify do
        expect(serialize('foobar')).to eq("$6\r\nfoobar\r\n")
      end

      specify do
        expect(serialize(:foobar)).to eq("$6\r\nfoobar\r\n")
      end
    end

    context 'RError' do
      specify do
        error = described_class::RError.new('Bar')
        expect(serialize(error)).to eq("-Bar\r\n")
      end
    end

    context 'RArray' do
      specify do
        expect(serialize([])).to eq("*0\r\n")
      end

      specify do
        expect(serialize(['foo', 'bar'])).to eq("*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n")
      end

      specify do
        expect(serialize([1, 2 ,3])).to eq("*3\r\n:1\r\n:2\r\n:3\r\n")
      end

      specify do
        out = "*5\r\n:1\r\n:2\r\n:3\r\n:4\r\n$12\r\nfoobarfoobar\r\n"
        expect(serialize([1, 2, 3, 4, 'foobarfoobar'])).to eq(out)
      end

      specify do
        out = "*2\r\n*3\r\n:1\r\n:2\r\n:3\r\n*2\r\n$3\r\nFoo\r\n-Bar\r\n"
        err = described_class::RError.new('Bar')
        expect(serialize([[1, 2, 3], ['Foo', err]])).to eq(out)
      end
    end

    context 'SerializerError' do
      specify do
        error = described_class::SerializerError
        expect { serialize({}) }.to raise_error(error, 'Hash type is unsupported')
      end
    end
  end

  describe '.parse' do
    def parse(io)
      io = StringIO.new(io) if io.is_a?(String)
      described_class::parse(io)
    end

    context 'Simple String' do
      specify do
        expect(parse("+OK\r\n")).to eq('OK')
      end
    end

    context 'Integer' do
      specify do
        expect(parse(":0\r\n")).to eq(0)
      end

      specify do
        expect(parse(":1000\r\n")).to eq(1000)
      end
    end

    context 'Bulk String' do
      specify do
        expect(parse("$-1\r\n")).to eq(nil)
      end

      specify do
        expect(parse("$0\r\n\r\n")).to eq('')
      end

      specify do
        expect(parse("$6\r\nfoobar\r\n")).to eq('foobar')
      end

      specify do
        expect(parse("$12\r\nfoobarfoobar\r\n")).to eq('foobarfoobar')
      end
    end

    context 'RError' do
      specify do
        err = parse("-Error message\r\n")
        expect(err).to be_a(described_class::RError)
        expect(err.message).to eq('Error message')
      end

      specify do
        err = parse("-ERR unknown command 'foobar'\r\n")
        expect(err).to be_a(described_class::RError)
        expect(err.message).to eq("ERR unknown command 'foobar'")
      end

      specify do
        err = parse("-WRONGTYPE Operation against a key holding the wrong kind of value\r\n")
        expect(err).to be_a(described_class::RError)
        expect(err.message).to eq('WRONGTYPE Operation against a key holding the wrong kind of value')
      end
    end

    context 'Array' do
      specify do
        response = "*3\r\n$3\r\nfoo\r\n$-1\r\n$3\r\nbar\r\n"
        expect(parse(response)).to eq(['foo', nil, 'bar'])
      end

      specify do
        expect(parse("*0\r\n")).to eq([])
      end

      specify do
        expect(parse("*-1\r\n")).to eq(nil)
      end

      specify do
        expect(parse("*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n")).to eq(['foo', 'bar'])
      end

      specify do
        expect(parse("*3\r\n:1\r\n:20\r\n:-3\r\n")).to eq([1, 20, -3])
      end

      specify do
        response = "*5\r\n:1\r\n:2\r\n:3\r\n:4\r\n$12\r\nfoobarfoobar\r\n"
        expect(parse(response)).to eq([1, 2, 3, 4, 'foobarfoobar'])
      end

      specify do
        response = "*10\r\n:1\r\n:2\r\n:3\r\n:4\r\n:5\r\n:6\r\n:7\r\n:8\r\n:9\r\n:10\r\n"
        expect(parse(response)).to eq((1..10).to_a)
      end

      specify do
        response = "*2\r\n*3\r\n:1\r\n:2\r\n*1\r\n+OK\r\n*2\r\n$3\r\nFoo\r\n-Bar\r\n"
        err = described_class::RError.new('Bar')
        expect(parse(response)).to eq([[1, 2, ['OK']], ['Foo', err]])
      end
    end

    context 'ParserError' do
      specify do
        error = described_class::ParserError
        error_msg = 'Unsupported response type'

        expect { parse("#3\r0\nWTF") }.to raise_error(error, error_msg)
      end
    end
  end
end
