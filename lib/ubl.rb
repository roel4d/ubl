require_relative "ubl/builder"
require_relative "ubl/validate"

##
# Generate and validate UBL (Universal Business Language) documents,
# such as invoices and credit notes, compliant with the Peppol network.
module Ubl
  class Invoice < UblBuilder
    ##
    # Creates a new Invoice instance.
    #
    # == Parameters
    # * +extension+ - (String) Optional. Set to +"UBL_BE"+ to generate UBL.BE compliant invoices
    #   for Belgian requirements. Defaults to +nil+ for standard PEPPOL format.
    #
    def initialize(extension = nil)
      super
    end

    def build
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.Invoice(namespaces) do
          build_header(xml) do |xml|
            xml["cbc"].InvoiceTypeCode "380"
          end
          build_document_reference(xml, "CommercialInvoice")
          build_content(xml)
        end
      end
      builder.to_xml
    end
  end

  class CreditNote < UblBuilder
    ##
    # Creates a new CreditNote instance.
    #
    # == Parameters
    # * +extension+ - (String) Optional. Set to +"UBL_BE"+ to generate UBL.BE compliant
    #   credit notes for Belgian requirements. Defaults to +nil+ for standard PEPPOL format.
    #
    def initialize(extension = nil)
      super
    end

    def build
      builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
        xml.CreditNote(namespaces.merge("xmlns" => "urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2")) do
          build_header(xml) do |xml|
            xml["cbc"].CreditNoteTypeCode "381"
          end
          build_document_reference(xml, "CreditNote")
          build_content(xml)
        end
      end
      builder.to_xml
    end
  end

  ##
  # Validate an invoice
  #
  # == Parameters
  # * +path+       - The path to the XML invoice that needs validation.
  # * +extension+  - Set to +"UBL_BE"+ to generate UBL.BE compliant documents.
  #                  Defaults to +nil+ for standard PEPPOL format.
  # * +schematron+ - If +true+, run a Schematron validation using Docker.
  #                  Requires Docker to be installed and running. Defaults to +true+.
  def self.validate_invoice(path, extension: nil, schematron: true)
    validator = Validator.new(extension:, schematron:)
    validator.validate_invoice(path)
  end

  ##
  # Validate a credit note
  #
  # == Parameters
  # * +path+       - The path to the XML credit note that needs validation.
  # * +extension+  - Set to +"UBL_BE"+ to generate UBL.BE compliant documents.
  #                  Defaults to +nil+ for standard PEPPOL format.
  # * +schematron+ - If +true+, run a Schematron validation using Docker.
  #                  Requires Docker to be installed and running. Defaults to +true+.
  def self.validate_credit_note(path, extension: nil, schematron: true)
    validator = Validator.new(extension:, schematron:)
    validator.validate_credit_note(path)
  end
end
