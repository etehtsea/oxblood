require 'oxblood/commands/geo'

RSpec.describe Oxblood::Commands::Geo do
  include_context 'test session'

  describe '#geoadd', if: server_newer_than('3.2.0') do
    specify do
      items = [13.361389, 38.115556, 'Palermo', 15.087269, 37.502669, 'Catania']
      expect(subject.geoadd(*items.unshift('Sicily'))).to eq(2)
    end
  end

  describe '#geohash', if: server_newer_than('3.2.0') do
    specify do
      args = %w(GEOADD Sicily 13.361389 38.115556 Palermo 15.087269 37.502669 Catania)
      subject.run_command(*args)

      result = %w(sqc8b49rny0 sqdtr74hyu0)
      expect(subject.geohash('Sicily', 'Palermo', 'Catania')).to eq(result)
    end
  end

  describe '#geopos', if: server_newer_than('3.2.0') do
    specify do
      args = %w(GEOADD Sicily 13.361389 38.115556 Palermo 15.087269 37.502669 Catania)
      subject.run_command(*args)

      result = [
        %w(13.36138933897018433 38.11555639549629859),
        %w(15.08726745843887329 37.50266842333162032),
        nil
      ]
      expect(subject.geopos('Sicily', 'Palermo', 'Catania', 'NonExisting')).to eq(result)
    end
  end

  describe '#geodist', if: server_newer_than('3.2.0') do
    specify do
      args = %w(GEOADD Sicily 13.361389 38.115556 Palermo 15.087269 37.502669 Catania)
      subject.run_command(*args)

      expect(subject.geodist('Sicily', 'Palermo', 'Catania')).to eq('166274.1516')
      expect(subject.geodist('Sicily', 'Palermo', 'Catania', :km)).to eq('166.2742')
      expect(subject.geodist('Sicily', 'Palermo', 'Catania', :mi)).to eq('103.3182')
      expect(subject.geodist('Sicily', 'Foo', 'Bar')).to be_nil
    end
  end

  describe '#georadius', if: server_newer_than('3.2.0') do
    def georadius(opts)
      subject.georadius('Sicily', 15, 37, 200, :km, opts)
    end

    before do
      args = %w(GEOADD Sicily 13.361389 38.115556 Palermo 15.087269 37.502669 Catania)
      subject.run_command(*args)
    end

    specify do
      withdist = [%w(Palermo 190.4424), %w(Catania 56.4413)]
      expect(georadius(withdist: true)).to eq(withdist)
    end

    specify do
      withcoord = [
        ['Palermo', %w(13.36138933897018433 38.11555639549629859)],
        ['Catania', %w(15.08726745843887329 37.50266842333162032)]
      ]

      expect(georadius(withcoord: true)).to eq(withcoord)
    end

    specify do
      both = [
        ['Palermo', '190.4424', %w(13.36138933897018433 38.11555639549629859)],
        ['Catania', '56.4413', %w(15.08726745843887329 37.50266842333162032)]
      ]

      expect(georadius(withdist: true, withcoord: true)).to eq(both)
    end

    specify do
      all = [
        [
          'Palermo',
          '190.4424',
          3479099956230698,
          %w(13.36138933897018433 38.11555639549629859)
        ],
        [
          'Catania',
          '56.4413',
          3479447370796909,
          %w(15.08726745843887329 37.50266842333162032)
        ]
      ]

      expect(georadius(withdist: true, withcoord: true, withhash: true)).to eq(all)
    end

    context 'ordering' do
      it 'ASC' do
        expect(georadius(order: :asc)).to eq(%w(Catania Palermo))
        expect(georadius(order: :asc, count: 1)).to eq(%w(Catania))
      end

      it 'DESC' do
        expect(georadius(order: :desc)).to eq(%w(Palermo Catania))
        expect(georadius(order: :desc, count: 1)).to eq(%w(Palermo))
      end
    end

    context 'STORE option' do
      specify do
        expect(georadius(store: 'Sicily2')).to eq(2)
      end

      it 'with COUNT' do
        expect(georadius(count: 1, store: 'Sicily2')).to eq(1)
      end

      it 'incompatible with WITH* options' do
        response = georadius(withdist: true, store: 'Wrong')
        expect(response).to be_a(Oxblood::Protocol::RError)
      end
    end

    context 'STOREDIST option' do
      specify do
        expect(georadius(storedist: 'Sicily2')).to eq(2)
      end

      it 'with COUNT' do
        expect(georadius(count: 1, storedist: 'Sicily2')).to eq(1)
      end

      it 'incompatible with WITH* options' do
        response = georadius(withdist: true, storedist: 'Wrong')
        expect(response).to be_a(Oxblood::Protocol::RError)
      end
    end
  end

  describe '#georadiusbymember', if: server_newer_than('3.2.0') do
    def georadiusbymember(opts)
      subject.georadiusbymember('Sicily', 'Agrigento', 100, :km, opts)
    end

    before do
      args = %w(
        GEOADD Sicily
        13.361389 38.115556 Palermo
        15.087269 37.502669 Catania
        13.583333 37.316667 Agrigento
      )
      subject.run_command(*args)
    end

    specify do
      withdist = [%w(Agrigento 0.0000), %w(Palermo 90.9778)]
      expect(georadiusbymember(withdist: true)).to eq(withdist)
    end

    specify do
      withcoord = [
        ['Agrigento', %w(13.5833314061164856 37.31666804993816555)],
        ['Palermo', %w(13.36138933897018433 38.11555639549629859)]
      ]

      expect(georadiusbymember(withcoord: true)).to eq(withcoord)
    end

    specify do
      both = [
        ['Agrigento', '0.0000', %w(13.5833314061164856 37.31666804993816555)],
        ['Palermo', '90.9778', %w(13.36138933897018433 38.11555639549629859)]
      ]

      expect(georadiusbymember(withdist: true, withcoord: true)).to eq(both)
    end

    specify do
      all = [
        [
          'Agrigento',
          '0.0000',
          3479030013248308,
          %w(13.5833314061164856 37.31666804993816555)
        ],
        [
          'Palermo',
          '90.9778',
          3479099956230698,
          %w(13.36138933897018433 38.11555639549629859)
        ]
      ]

      expect(georadiusbymember(withdist: true, withcoord: true, withhash: true)).to eq(all)
    end

    context 'ordering' do
      it 'ASC' do
        expect(georadiusbymember(order: :asc)).to eq(%w(Agrigento Palermo))
        expect(georadiusbymember(order: :asc, count: 1)).to eq(%w(Agrigento))
      end

      it 'DESC' do
        expect(georadiusbymember(order: :desc)).to eq(%w(Palermo Agrigento))
        expect(georadiusbymember(order: :desc, count: 1)).to eq(%w(Palermo))
      end
    end

    context 'STORE option' do
      specify do
        expect(georadiusbymember(store: 'Sicily2')).to eq(2)
      end

      it 'with COUNT' do
        expect(georadiusbymember(count: 1, store: 'Sicily2')).to eq(1)
      end

      it 'incompatible with WITH* options' do
        response = georadiusbymember(withdist: true, store: 'Wrong')
        expect(response).to be_a(Oxblood::Protocol::RError)
      end
    end

    context 'STOREDIST option' do
      specify do
        expect(georadiusbymember(storedist: 'Sicily2')).to eq(2)
      end

      it 'with COUNT' do
        expect(georadiusbymember(count: 1, storedist: 'Sicily2')).to eq(1)
      end

      it 'incompatible with WITH* options' do
        response = georadiusbymember(withdist: true, storedist: 'Wrong')
        expect(response).to be_a(Oxblood::Protocol::RError)
      end
    end
  end
end
