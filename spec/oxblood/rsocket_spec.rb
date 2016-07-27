# coding: utf-8
require 'oxblood/rsocket'

RSpec.describe Oxblood::RSocket do
  describe '#timeout' do
    specify do
      expect(subject.timeout).to be_within(0.1).of(1.0)
    end

    specify do
      subject.timeout = 5
      expect(subject.timeout).to eq(5)
    end
  end

  describe '#close' do
    specify do
      expect(subject.close).to be_nil
      expect(subject.instance_variable_get(:@buffer)).to be_empty
      expect(subject.instance_variable_get(:@socket)).to be_nil
    end

    it 'do not raise even if called on closed socket' do
      subject.instance_variable_get(:@socket).close
      expect(subject.close).to be_nil
    end
  end

  describe '#connected?' do
    specify do
      expect(subject.connected?).to eq(true)
    end

    specify do
      subject.close
      expect(subject.connected?).to eq(false)
    end
  end

  describe '#read' do
    specify do
      subject.write("PING\r\n")
      response = "+PONG\r\n"
      expect(subject.read(response.bytesize)).to eq(response)
    end

    it 'slice multibyte strings properly' do
      subject.write("*2\r\n$4\r\nECHO\r\n$6\r\nабв\r\n")
      subject.gets("\r\n")
      expect(subject.read(2)).to eq("\xD0\xB0".b)
    end

    context 'timeout' do
      let(:timeout_error) do
        described_class::TimeoutError
      end

      it 'closes socket in case of timeout error' do
        socket = double('socket')
        allow(socket).to receive(:read_nonblock).and_raise(IO::EAGAINWaitReadable)
        allow(socket).to receive(:close).and_return(nil)
        allow(IO).to receive(:select).and_return(false)
        allow(subject).to receive(:socket).and_return(socket)
        allow(subject).to receive(:close).and_call_original

        expect { subject.read(1) }.to raise_error(timeout_error)
        expect(subject).to have_received(:close)
      end

      it 'if read more than available' do
        subject.timeout = 0.1
        expect { subject.read(42) }.to raise_error(timeout_error)
      end
    end

    context 'eof' do
      specify do
        socket = double('socket')
        allow(socket).to receive(:read_nonblock).and_raise(EOFError)
        allow(socket).to receive(:close).and_return(nil)
        allow(subject).to receive(:socket).and_return(socket)
        allow(subject).to receive(:close).and_call_original

        expect { subject.read(1) }.to raise_error(Errno::ECONNRESET)
        expect(subject).to have_received(:close)
      end
    end
  end

  describe '#gets' do
    let(:sep) do
      "\r\n".freeze
    end

    specify do
      subject.write("PING\r\n")
      response = "+PONG\r\n"
      expect(subject.gets(sep)).to eq(response)
    end

    context 'timeout' do
      let(:timeout_error) do
        described_class::TimeoutError
      end

      it 'closes socket in case of timeout error' do
        socket = double('socket')
        allow(socket).to receive(:read_nonblock).and_raise(IO::EAGAINWaitReadable)
        allow(socket).to receive(:close).and_return(nil)
        allow(IO).to receive(:select).and_return(false)
        allow(subject).to receive(:socket).and_return(socket)
        allow(subject).to receive(:close).and_call_original

        expect { subject.gets(sep) }.to raise_error(timeout_error)
        expect(subject).to have_received(:close)
      end
    end

    context 'eof' do
      specify do
        socket = double('socket')
        allow(socket).to receive(:read_nonblock).and_raise(EOFError)
        allow(socket).to receive(:close).and_return(nil)
        allow(subject).to receive(:socket).and_return(socket)
        allow(subject).to receive(:close).and_call_original

        expect { subject.gets(sep) }.to raise_error(Errno::ECONNRESET)
        expect(subject).to have_received(:close)
      end
    end
  end
end
