require_relative '../unit_helper'

describe Watir::Locators::Element::SelectorBuilder do
  let(:attributes) { @attributes || Watir::HTMLElement.attribute_list }
  let(:selector_builder) { described_class.new(attributes) }

  describe '#build' do
    it 'without any arguments' do
      selector = {}
      built = {xpath: './/*'}

      expect(selector_builder.build(selector)).to eq built
    end

    context 'with xpath or css' do
      it 'locates with xpath only' do
        selector = {xpath: './/div'}
        built = selector.dup

        expect(selector_builder.build(selector)).to eq built
      end

      it 'locates with css only' do
        selector = {css: 'div'}
        built = selector.dup

        expect(selector_builder.build(selector)).to eq built
      end

      it 'locates when attributes combined with xpath' do
        selector = {xpath: './/div', random: 'foo'}
        built = selector.dup

        expect(selector_builder.build(selector)).to eq built
      end

      it 'locates when attributes combined with css' do
        selector = {css: 'div', random: 'foo'}
        built = selector.dup

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when using xpath & css' do
        selector = {xpath: './/*', css: 'div'}
        msg = ':xpath and :css cannot be combined ({:xpath=>".//*", :css=>"div"})'

        expect { selector_builder.build(selector) }.to raise_exception Watir::Exception::LocatorException, msg
      end

      it 'raises exception when not a String' do
        selector = {xpath: 7}
        msg = /expected one of \[String\], got 7:(Fixnum|Integer)/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with tag_name' do
      it 'with String equals' do
        selector = {tag_name: 'div'}
        built = {xpath: ".//*[local-name()='div']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'with simple Regexp contains' do
        selector = {tag_name: /div/}
        built = {xpath: ".//*[contains(local-name(), 'div')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'with Symbol' do
        selector = {tag_name: :div}
        built = {xpath: ".//*[local-name()='div']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when not a String or Regexp' do
        selector = {tag_name: 7}
        msg = /expected one of \[String, Regexp, Symbol\], got 7:(Fixnum|Integer)/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with class names' do
      it 'class_name is converted to class' do
        selector = {class_name: 'user'}
        built = {xpath: ".//*[contains(concat(' ', @class, ' '), ' user ')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      # TODO: This functionality is deprecated with "class_array"
      it 'values with spaces' do
        selector = {class_name: 'multiple classes here'}
        built = {xpath: ".//*[contains(concat(' ', @class, ' '), ' multiple classes here ')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'single String concatenates' do
        selector = {class: 'user'}
        built = {xpath: ".//*[contains(concat(' ', @class, ' '), ' user ')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'Array of String concatenates with and' do
        selector = {class: %w[multiple here]}
        built = {xpath: ".//*[contains(concat(' ', @class, ' '), ' multiple ') and " \
"contains(concat(' ', @class, ' '), ' here ')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'merges values when class and class_name are both used' do
        selector = {class: 'foo', class_name: 'bar'}
        built = {xpath: ".//*[contains(concat(' ', @class, ' '), ' foo ') and " \
"contains(concat(' ', @class, ' '), ' bar ')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'simple Regexp contains' do
        selector = {class_name: /use/}
        built = {xpath: ".//*[contains(@class, 'use')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'Array of Regexp contains with and' do
        selector = {class: [/mult/, /her/]}
        built = {xpath: ".//*[contains(@class, 'mult') and contains(@class, 'her')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'single negated String concatenates with not' do
        selector = {class: '!multiple'}
        built = {xpath: ".//*[not(contains(concat(' ', @class, ' '), ' multiple '))]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'single Boolean true provides the at' do
        selector = {class: true}
        built = {xpath: './/*[@class]'}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'single Boolean false provides the not atat' do
        selector = {class: false}
        built = {xpath: './/*[not(@class)]'}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'Array of mixed String, Regexp and Boolean contains and concatenates with and and not' do
        selector = {class: [/mult/, 'classes', '!here']}
        built = {xpath: ".//*[contains(@class, 'mult') and contains(concat(' ', @class, ' '), ' classes ') " \
"and not(contains(concat(' ', @class, ' '), ' here '))]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when not a String or Regexp or Array' do
        selector = {class: 7}
        msg = /expected one of \[String, Regexp, TrueClass, FalseClass\], got 7:(Fixnum|Integer)/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when Array values are not a String or Regexp' do
        selector = {class: [7]}
        msg = /expected one of \[String, Regexp, TrueClass, FalseClass\], got 7:(Fixnum|Integer)/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when class array is empty' do
        selector = {class: []}
        msg = 'Can not locate elements with an empty Array for :class'

        expect { selector_builder.build(selector) }.to raise_exception Watir::Exception::LocatorException, msg
      end
    end

    context 'with attributes as predicates' do
      it 'with href attribute' do
        selector = {href: 'watirspec.css'}
        built = {xpath: ".//*[normalize-space(@href)='watirspec.css']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'with string attribute' do
        selector = {'name' => 'user_new'}
        built = {xpath: ".//*[@name='user_new']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'with String equals' do
        selector = {name: 'user_new'}
        built = {xpath: ".//*[@name='user_new']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'with TrueClass no equals' do
        selector = {tag_name: 'input', name: true}
        built = {xpath: ".//*[local-name()='input'][@name]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'with FalseClass not with no equals' do
        selector = {tag_name: 'input', name: false}
        built = {xpath: ".//*[local-name()='input'][not(@name)]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'with multiple attributes: no equals and not with no equals and equals' do
        selector = {readonly: true, foo: false, id: 'good_luck'}
        built = {xpath: ".//*[@readonly and not(@foo) and @id='good_luck']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when attribute value is not a Boolean, String or Regexp' do
        selector = {foo: 7}
        msg = /expected one of \[String, Regexp, TrueClass, FalseClass\], got 7:(Fixnum|Integer)/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when attribute key is not a String or Regexp' do
        selector = {7 => 'foo'}
        msg = /Unable to build XPath using 7:(Fixnum|Integer)/

        expect { selector_builder.build(selector) }.to raise_exception Watir::Exception::LocatorException, msg
      end
    end

    context 'with attributes as partials' do
      it 'with Regexp' do
        selector = {name: /user/}
        built = {xpath: ".//*[contains(@name, 'user')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'with multiple Regexp attributes separated by and' do
        selector = {readonly: /read/, id: /good/}
        built = {xpath: ".//*[contains(@readonly, 'read') and contains(@id, 'good')]"}

        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with text' do
      it 'String uses normalize space equals' do
        selector = {text: 'Add user'}
        built = {xpath: ".//*[normalize-space()='Add user']"}

        expect(selector_builder.build(selector)).to eq built
      end

      # Deprecated with :caption
      it 'with caption attribute' do
        selector = {caption: 'Add user'}
        built = {xpath: ".//*[normalize-space()='Add user']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when text is not a String or Regexp' do
        selector = {text: 7}
        msg = /expected one of \[String, Regexp\], got 7:(Fixnum|Integer)/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with index' do
      it 'positive' do
        selector = {tag_name: 'div', index: 7}
        built = {xpath: "(.//*[local-name()='div'])[8]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'negative' do
        selector = {tag_name: 'div', index: -7}
        built = {xpath: "(.//*[local-name()='div'])[last()-6]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'last' do
        selector = {tag_name: 'div', index: -1}
        built = {xpath: "(.//*[local-name()='div'])[last()]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'does not return index if it is zero' do
        selector = {tag_name: 'div', index: 0}
        built = {xpath: ".//*[local-name()='div']"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when index is not an Integer' do
        selector = {index: 'foo'}
        msg = /expected one of \[(Integer|Fixnum)\], got "foo":String/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end

    context 'with labels' do
      it 'locates the element associated with the label element located by the text of the provided label key' do
        selector = {label: 'Cars'}
        built = {xpath: ".//*[@id=//label[normalize-space()='Cars']/@for "\
"or parent::label[normalize-space()='Cars']]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'does not use the label element when label is a valid attribute' do
        @attributes ||= Watir::Option.attribute_list

        selector = {tag_name: 'option', label: 'Germany'}
        built = {xpath: ".//*[local-name()='option'][@label='Germany']"}

        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with adjacent locators' do
      it 'raises exception when not a Symbol' do
        selector = {adjacent: 'foo', index: 0}
        msg = 'expected one of [Symbol], got "foo":String'

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when not a valid value' do
        selector = {adjacent: :foo, index: 0}
        msg = 'Unable to process adjacent locator with foo'

        expect { selector_builder.build(selector) }.to raise_exception Watir::Exception::LocatorException, msg
      end

      describe '#parent' do
        it 'with no other arguments' do
          selector = {adjacent: :ancestor, index: 0}
          built = {xpath: './ancestor::*[1]'}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with index' do
          selector = {adjacent: :ancestor, index: 2}
          built = {xpath: './ancestor::*[3]'}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with multiple locators' do
          selector = {adjacent: :ancestor, id: true, tag_name: 'div', class: 'ancestor', index: 1}
          built = {xpath: "./ancestor::*[local-name()='div']"\
"[contains(concat(' ', @class, ' '), ' ancestor ')][@id][2]"}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'raises an exception if text locator is used' do
          selector = {adjacent: :ancestor, index: 0, text: 'Foo'}
          msg = 'Can not find parent element with text locator'
          expect { selector_builder.build(selector) }
            .to raise_exception Watir::Exception::LocatorException, msg
        end
      end

      describe '#following_sibling' do
        it 'with no other arguments' do
          selector = {adjacent: :following, index: 0}
          built = {xpath: './following-sibling::*[1]'}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with index' do
          selector = {adjacent: :following, index: 2}
          built = {xpath: './following-sibling::*[3]'}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with multiple locators' do
          selector = {adjacent: :following, tag_name: 'div', class: 'b', index: 0, id: true}
          built = {xpath: "./following-sibling::*[local-name()='div']"\
"[contains(concat(' ', @class, ' '), ' b ')][@id][1]"}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with text' do
          selector = {adjacent: :following, text: 'Third', index: 0}
          built = {xpath: "./following-sibling::*[normalize-space()='Third'][1]"}

          expect(selector_builder.build(selector)).to eq built
        end
      end

      describe '#previous_sibling' do
        it 'with no other arguments' do
          selector = {adjacent: :preceding, index: 0}
          built = {xpath: './preceding-sibling::*[1]'}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with index' do
          selector = {adjacent: :preceding, index: 2}
          built = {xpath: './preceding-sibling::*[3]'}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with multiple locators' do
          selector = {adjacent: :preceding, tag_name: 'div', class: 'b', id: true, index: 0}
          built = {xpath: "./preceding-sibling::*[local-name()='div']"\
"[contains(concat(' ', @class, ' '), ' b ')][@id][1]"}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with text' do
          selector = {adjacent: :preceding, text: 'Second', index: 0}
          built = {xpath: "./preceding-sibling::*[normalize-space()='Second'][1]"}

          expect(selector_builder.build(selector)).to eq built
        end
      end

      describe '#child' do
        it 'with no other arguments' do
          selector = {adjacent: :child, index: 0}
          built = {xpath: './child::*[1]'}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with index' do
          selector = {adjacent: :child, index: 2}
          built = {xpath: './child::*[3]'}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with multiple locators' do
          selector = {adjacent: :child, tag_name: 'div', class: 'b', id: true, index: 0}
          built = {xpath: "./child::*[local-name()='div']"\
"[contains(concat(' ', @class, ' '), ' b ')][@id][1]"}

          expect(selector_builder.build(selector)).to eq built
        end

        it 'with text' do
          selector = {adjacent: :child, text: 'Second', index: 0}
          built = {xpath: "./child::*[normalize-space()='Second'][1]"}

          expect(selector_builder.build(selector)).to eq built
        end
      end
    end

    context 'with multiple locators' do
      it 'locates using tag name, class, attributes and text' do
        selector = {tag_name: 'div', class: 'content', contenteditable: 'true', text: 'Foo'}
        built = {xpath: ".//*[local-name()='div'][contains(concat(' ', @class, ' '), ' content ')]" \
"[normalize-space()='Foo'][@contenteditable='true']"}

        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with simple Regexp' do
      it 'handles spaces' do
        selector = {title: /od Lu/}
        built = {xpath: ".//*[contains(@title, 'od Lu')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'handles escaped characters' do
        selector = {src: %r{ages/but}}
        built = {xpath: ".//*[contains(@src, 'ages/but')]"}

        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'with complex Regexp' do
      it 'handles wildcards' do
        selector = {src: /ages.*but/}
        built = {xpath: ".//*[contains(@src, 'ages') and contains(@src, 'but')]", src: /ages.*but/}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'handles optional characters' do
        selector = {src: /ages ?but/}
        built = {xpath: ".//*[contains(@src, 'ages') and contains(@src, 'but')]", src: /ages ?but/}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'handles anchors' do
        selector = {name: /^new_user_image$/}
        built = {xpath: ".//*[contains(@name, 'new_user_image')]", name: /^new_user_image$/}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'handles beginning anchor' do
        selector = {src: /^i/}
        built = {xpath: ".//*[starts-with(@src, 'i')]"}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'does not use starts-with if visible locator used' do
        selector = {id: /^vis/, visible_text: 'shown div'}
        built = {xpath: ".//*[contains(@id, 'vis')]", id: /^vis/, visible_text: 'shown div'}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'handles case insensitive' do
        selector = {action: /me/i}
        built = {xpath: './/*[contains(translate(@action,' \
"'ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸŽŠŒ'," \
"'abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿžšœ'), 'me')]"}

        expect(selector_builder.build(selector)).to eq built
      end
    end

    context 'returns locators that can not be directly translated' do
      it 'attribute with complicated Regexp at end' do
        selector = {action: /me$/}
        built = {xpath: ".//*[contains(@action, 'me')]", action: /me$/}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'class with complicated Regexp' do
        selector = {class: /he?r/}
        built = {xpath: ".//*[contains(@class, 'h') and contains(@class, 'r')]", class: [/he?r/]}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'text with any Regexp' do
        selector = {text: /Add/}
        built = {xpath: './/*', text: /Add/}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'visible' do
        selector = {tag_name: 'div', visible: true}
        built = {xpath: ".//*[local-name()='div']", visible: true}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'not visible' do
        selector = {tag_name: 'span', visible: false}
        built = {xpath: ".//*[local-name()='span']", visible: false}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'visible text' do
        selector = {tag_name: 'span', visible_text: 'foo'}
        built = {xpath: ".//*[local-name()='span']", visible_text: 'foo'}

        expect(selector_builder.build(selector)).to eq built
      end

      it 'raises exception when visible is not boolean' do
        selector = {visible: 'foo'}
        msg = 'expected one of [TrueClass, FalseClass], got "foo":String'

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end

      it 'raises exception when visible text is not a String or Regexp' do
        selector = {visible_text: 7}
        msg = /expected one of \[String, Regexp\], got 7:(Fixnum|Integer)/

        expect { selector_builder.build(selector) }.to raise_exception TypeError, msg
      end
    end
  end
end