class NotesTopic {
  final String id;
  final String name;
  final int pdfCount;
  final bool isPremium;
  final double price;
  final List<NotesPdf> pdfs;
  final bool isSpecial;

  const NotesTopic({
    required this.id,
    required this.name,
    required this.pdfCount,
    required this.isPremium,
    required this.price,
    required this.pdfs,
    required this.isSpecial,
  });

  factory NotesTopic.fromJson(Map<String, dynamic> json) {
    return NotesTopic(
      id: json['id'] as String,
      name: json['name'] as String,
      pdfCount: json['pdfCount'] as int,
      isPremium: json['isPremium'] as bool,
      price: (json['price'] as num).toDouble(),
      pdfs: (json['pdfs'] as List)
          .map((pdf) => NotesPdf.fromJson(pdf))
          .toList(),
      isSpecial: json['isSpecial'] as bool? ?? false,
    );
  }
}

class NotesPdf {
  final String id;
  final String name;
  final int pageCount;
  final String downloadUrl;
  final bool isPremium;

  const NotesPdf({
    required this.id,
    required this.name,
    required this.pageCount,
    required this.downloadUrl,
    required this.isPremium,
  });

  factory NotesPdf.fromJson(Map<String, dynamic> json) {
    return NotesPdf(
      id: json['id'] as String,
      name: json['name'] as String,
      pageCount: json['pageCount'] as int,
      downloadUrl: json['downloadUrl'] as String,
      isPremium: json['isPremium'] as bool,
    );
  }
}

class NotesService {
  static Future<List<NotesTopic>> fetchNotesTopics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    const dummyData = [
      // Core Legal Subjects (संविधान र कानून) - 12 subjects - Updated
      {
        'id': 'notes_1',
        'name': 'संवैधानिक कानून',
        'pdfCount': 3,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_1_1',
            'name': 'संविधानको मौलिक सिद्धान्त',
            'pageCount': 45,
            'downloadUrl': 'https://example.com/constitution_basics.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_1_2',
            'name': 'मौलिक अधिकार र कर्तव्य',
            'pageCount': 38,
            'downloadUrl': 'https://example.com/fundamental_rights.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_1_3',
            'name': 'राज्यको नीति निर्देशक सिद्धान्त',
            'pageCount': 52,
            'downloadUrl': 'https://example.com/directive_principles.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_2',
        'name': 'प्रशासकीय कानून',
        'pdfCount': 2,
        'isPremium': true,
        'price': 25.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_2_1',
            'name': 'प्रशासनिक न्याय',
            'pageCount': 67,
            'downloadUrl': 'https://example.com/administrative_justice.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_2_2',
            'name': 'सरकारी निर्णय प्रक्रिया',
            'pageCount': 89,
            'downloadUrl': 'https://example.com/decision_making.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_3',
        'name': 'मुलुकी अपराध संहिता',
        'pdfCount': 4,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_3_1',
            'name': 'अपराधको परिभाषा र वर्गीकरण',
            'pageCount': 34,
            'downloadUrl': 'https://example.com/crime_definition.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_3_2',
            'name': 'दण्ड प्रणाली',
            'pageCount': 41,
            'downloadUrl': 'https://example.com/punishment_system.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_3_3',
            'name': 'अपराधिक प्रक्रिया',
            'pageCount': 28,
            'downloadUrl': 'https://example.com/criminal_procedure.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_3_4',
            'name': 'साक्ष्य कानून',
            'pageCount': 36,
            'downloadUrl': 'https://example.com/evidence_law.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_4',
        'name': 'मुलुकी फौजदारी कार्यविधि संहिता',
        'pdfCount': 2,
        'isPremium': true,
        'price': 30.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_4_1',
            'name': 'फौजदारी प्रक्रिया',
            'pageCount': 56,
            'downloadUrl': 'https://example.com/criminal_procedure_code.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_4_2',
            'name': 'अदालती प्रक्रिया',
            'pageCount': 72,
            'downloadUrl': 'https://example.com/court_procedure.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_5',
        'name': 'मुलुकी देवानी संहिता',
        'pdfCount': 3,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_5_1',
            'name': 'देवानी अधिकार',
            'pageCount': 48,
            'downloadUrl': 'https://example.com/civil_rights.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_5_2',
            'name': 'सम्पत्ति अधिकार',
            'pageCount': 62,
            'downloadUrl': 'https://example.com/property_rights.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_5_3',
            'name': 'अनुबन्ध कानून',
            'pageCount': 55,
            'downloadUrl': 'https://example.com/contract_law.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_6',
        'name': 'मुलुकी देवानी कार्यविधि संहिता',
        'pdfCount': 2,
        'isPremium': true,
        'price': 28.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_6_1',
            'name': 'देवानी प्रक्रिया',
            'pageCount': 58,
            'downloadUrl': 'https://example.com/civil_procedure.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_6_2',
            'name': 'अदालती कार्यविधि',
            'pageCount': 45,
            'downloadUrl': 'https://example.com/court_procedure_civil.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_7',
        'name': 'फौजदारी कसूर (सजाय निर्धारण तथा कार्यान्वयन) ऐन',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_7_1',
            'name': 'सजाय निर्धारण',
            'pageCount': 42,
            'downloadUrl': 'https://example.com/sentencing.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_7_2',
            'name': 'सजाय कार्यान्वयन',
            'pageCount': 38,
            'downloadUrl': 'https://example.com/sentence_execution.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_8',
        'name': 'न्याय प्रशासन ऐन र प्रमाण कानून',
        'pdfCount': 3,
        'isPremium': true,
        'price': 32.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_8_1',
            'name': 'न्याय प्रशासन',
            'pageCount': 65,
            'downloadUrl': 'https://example.com/justice_administration.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_8_2',
            'name': 'प्रमाण कानून',
            'pageCount': 52,
            'downloadUrl': 'https://example.com/evidence_law_detailed.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_8_3',
            'name': 'अदालती प्रक्रिया',
            'pageCount': 48,
            'downloadUrl': 'https://example.com/court_proceedings.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_9',
        'name': 'नेपालको कानून प्रणाली',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_9_1',
            'name': 'कानून प्रणालीको विकास',
            'pageCount': 55,
            'downloadUrl': 'https://example.com/legal_system_development.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_9_2',
            'name': 'नेपाली कानूनको इतिहास',
            'pageCount': 43,
            'downloadUrl': 'https://example.com/nepal_legal_history.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_10',
        'name': 'विधिशास्त्र (विभिन्न सम्प्रदायको बारेमा मात्र)',
        'pdfCount': 3,
        'isPremium': true,
        'price': 35.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_10_1',
            'name': 'विधिशास्त्रको परिचय',
            'pageCount': 68,
            'downloadUrl': 'https://example.com/jurisprudence_intro.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_10_2',
            'name': 'विभिन्न सम्प्रदाय',
            'pageCount': 72,
            'downloadUrl': 'https://example.com/legal_schools.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_10_3',
            'name': 'कानूनी सिद्धान्त',
            'pageCount': 58,
            'downloadUrl': 'https://example.com/legal_theories.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_11',
        'name': 'कानून व्याख्यासम्बन्धी',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_11_1',
            'name': 'कानून व्याख्याको सिद्धान्त',
            'pageCount': 46,
            'downloadUrl': 'https://example.com/legal_interpretation.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_11_2',
            'name': 'व्याख्या विधि',
            'pageCount': 39,
            'downloadUrl': 'https://example.com/interpretation_methods.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_12',
        'name': 'अदालतका नियमावलीहरु',
        'pdfCount': 2,
        'isPremium': true,
        'price': 22.0,
        'isSpecial': false,
        'pdfs': [
          {
            'id': 'pdf_12_1',
            'name': 'सर्वोच्च अदालत नियमावली',
            'pageCount': 78,
            'downloadUrl': 'https://example.com/supreme_court_rules.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_12_2',
            'name': 'अपिल अदालत नियमावली',
            'pageCount': 65,
            'downloadUrl': 'https://example.com/appeal_court_rules.pdf',
            'isPremium': true,
          },
        ],
      },
      // Specialized Subjects (विशिष्टिकृत) - 19 subjects
      {
        'id': 'notes_13',
        'name': 'अन्तर्राष्ट्रिय कानून',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_13_1',
            'name': 'अन्तर्राष्ट्रिय संधि कानून',
            'pageCount': 78,
            'downloadUrl': 'https://example.com/international_treaty.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_13_2',
            'name': 'संयुक्त राष्ट्र संघ',
            'pageCount': 65,
            'downloadUrl': 'https://example.com/united_nations.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_14',
        'name': 'मानव अधिकारकानून',
        'pdfCount': 3,
        'isPremium': true,
        'price': 35.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_14_1',
            'name': 'मानव अधिकारको सार्वभौमिक घोषणा',
            'pageCount': 42,
            'downloadUrl': 'https://example.com/universal_declaration.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_14_2',
            'name': 'अन्तर्राष्ट्रिय मानव अधिकार संधि',
            'pageCount': 58,
            'downloadUrl': 'https://example.com/human_rights_treaty.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_14_3',
            'name': 'नेपालमा मानव अधिकार',
            'pageCount': 45,
            'downloadUrl': 'https://example.com/nepal_human_rights.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_15',
        'name': 'कम्पनी कानून',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_15_1',
            'name': 'कम्पनीको निगमन',
            'pageCount': 52,
            'downloadUrl': 'https://example.com/company_incorporation.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_15_2',
            'name': 'कम्पनीको प्रबन्धन',
            'pageCount': 48,
            'downloadUrl': 'https://example.com/company_management.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_16',
        'name': 'लैंगिक हिंसा नियन्त्रण कानून',
        'pdfCount': 2,
        'isPremium': true,
        'price': 28.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_16_1',
            'name': 'लैंगिक हिंसा नियन्त्रण ऐन',
            'pageCount': 44,
            'downloadUrl': 'https://example.com/gender_violence_act.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_16_2',
            'name': 'पीडितको अधिकार',
            'pageCount': 36,
            'downloadUrl': 'https://example.com/victim_rights.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_17',
        'name': 'बाल न्याय तथा बालबालिकासम्बन्धी ऐन',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_17_1',
            'name': 'बाल न्याय ऐन',
            'pageCount': 52,
            'downloadUrl': 'https://example.com/child_justice_act.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_17_2',
            'name': 'बाल अधिकार',
            'pageCount': 38,
            'downloadUrl': 'https://example.com/child_rights.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_18',
        'name': 'संगठित अपराध (मानव बेचविखन, लागू औषध, सम्पत्ति शुद्धीकरण)',
        'pdfCount': 3,
        'isPremium': true,
        'price': 40.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_18_1',
            'name': 'संगठित अपराध नियन्त्रण',
            'pageCount': 68,
            'downloadUrl': 'https://example.com/organized_crime.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_18_2',
            'name': 'मानव बेचविखन',
            'pageCount': 55,
            'downloadUrl': 'https://example.com/human_trafficking.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_18_3',
            'name': 'सम्पत्ति शुद्धीकरण',
            'pageCount': 42,
            'downloadUrl': 'https://example.com/money_laundering.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_19',
        'name': 'विद्युतीय कारोवार सम्बन्धी कानून',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_19_1',
            'name': 'इ-कमर्स कानून',
            'pageCount': 48,
            'downloadUrl': 'https://example.com/ecommerce_law.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_19_2',
            'name': 'साइबर अपराध',
            'pageCount': 56,
            'downloadUrl': 'https://example.com/cyber_crime.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_20',
        'name': 'भ्रष्टाचार निवारणसम्बन्धी कानून',
        'pdfCount': 2,
        'isPremium': true,
        'price': 30.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_20_1',
            'name': 'भ्रष्टाचार निवारण ऐन',
            'pageCount': 62,
            'downloadUrl': 'https://example.com/corruption_prevention.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_20_2',
            'name': 'लोक सेवा आयोग',
            'pageCount': 45,
            'downloadUrl': 'https://example.com/public_service_commission.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_21',
        'name': 'विवाद समाधानका वैकल्पिक उपायहरु',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_21_1',
            'name': 'मध्यस्थता',
            'pageCount': 38,
            'downloadUrl': 'https://example.com/mediation.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_21_2',
            'name': 'सुलह',
            'pageCount': 32,
            'downloadUrl': 'https://example.com/conciliation.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_22',
        'name': 'बौद्धिक सम्पत्तिसम्बन्धी कानून',
        'pdfCount': 2,
        'isPremium': true,
        'price': 25.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_22_1',
            'name': 'कापीराइट कानून',
            'pageCount': 52,
            'downloadUrl': 'https://example.com/copyright_law.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_22_2',
            'name': 'पेटेन्ट र ट्रेडमार्क',
            'pageCount': 48,
            'downloadUrl': 'https://example.com/patent_trademark.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_23',
        'name': 'कर कानून',
        'pdfCount': 2,
        'isPremium': true,
        'price': 20.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_23_1',
            'name': 'आयकर कानून',
            'pageCount': 68,
            'downloadUrl': 'https://example.com/income_tax.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_23_2',
            'name': 'मूल्य अभिवृद्धि कर',
            'pageCount': 45,
            'downloadUrl': 'https://example.com/vat.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_24',
        'name': 'अपराध पीडितसम्बन्धी कानून',
        'pdfCount': 2,
        'isPremium': true,
        'price': 22.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_24_1',
            'name': 'पीडितको अधिकार',
            'pageCount': 42,
            'downloadUrl': 'https://example.com/victim_rights_detailed.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_24_2',
            'name': 'पीडित सहायता',
            'pageCount': 35,
            'downloadUrl': 'https://example.com/victim_support.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_25',
        'name': 'व्यावसायिक आचार संहिता',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_25_1',
            'name': 'वकिल आचार संहिता',
            'pageCount': 38,
            'downloadUrl': 'https://example.com/lawyer_ethics.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_25_2',
            'name': 'न्यायाधीश आचार संहिता',
            'pageCount': 44,
            'downloadUrl': 'https://example.com/judge_ethics.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_26',
        'name': 'वातावरण कानून',
        'pdfCount': 2,
        'isPremium': true,
        'price': 26.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_26_1',
            'name': 'वातावरण संरक्षण ऐन',
            'pageCount': 58,
            'downloadUrl': 'https://example.com/environment_protection.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_26_2',
            'name': 'जलवायु परिवर्तन',
            'pageCount': 52,
            'downloadUrl': 'https://example.com/climate_change.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_27',
        'name': 'बीमा कानून',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_27_1',
            'name': 'बीमा कानून',
            'pageCount': 46,
            'downloadUrl': 'https://example.com/insurance_law.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_27_2',
            'name': 'बीमा नियमावली',
            'pageCount': 38,
            'downloadUrl': 'https://example.com/insurance_regulations.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_28',
        'name': 'श्रम कानून',
        'pdfCount': 2,
        'isPremium': true,
        'price': 24.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_28_1',
            'name': 'श्रम ऐन',
            'pageCount': 62,
            'downloadUrl': 'https://example.com/labor_act.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_28_2',
            'name': 'कामदार अधिकार',
            'pageCount': 48,
            'downloadUrl': 'https://example.com/worker_rights.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_29',
        'name': 'वैकिंग कसूर र बैंक तथा वित्तीय संस्थासम्बन्धी कानून',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_29_1',
            'name': 'बैंकिङ कानून',
            'pageCount': 55,
            'downloadUrl': 'https://example.com/banking_law.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_29_2',
            'name': 'वित्तीय संस्था',
            'pageCount': 42,
            'downloadUrl': 'https://example.com/financial_institutions.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_30',
        'name': 'अध्यागमन सम्बन्धी कानून',
        'pdfCount': 2,
        'isPremium': true,
        'price': 28.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_30_1',
            'name': 'अध्यागमन ऐन',
            'pageCount': 48,
            'downloadUrl': 'https://example.com/immigration_act.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_30_2',
            'name': 'नागरिकता कानून',
            'pageCount': 38,
            'downloadUrl': 'https://example.com/citizenship_law.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_31',
        'name': 'कानूनी अनुसन्धान',
        'pdfCount': 2,
        'isPremium': false,
        'price': 0.0,
        'isSpecial': true,
        'pdfs': [
          {
            'id': 'pdf_31_1',
            'name': 'कानूनी अनुसन्धान विधि',
            'pageCount': 44,
            'downloadUrl': 'https://example.com/legal_research_methods.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_31_2',
            'name': 'कानूनी लेखन',
            'pageCount': 36,
            'downloadUrl': 'https://example.com/legal_writing.pdf',
            'isPremium': false,
          },
        ],
      },
    ];

    return dummyData.map((data) => NotesTopic.fromJson(data)).toList();
  }

  // Dummy user premium status from API
  static Future<bool> fetchUserPremium() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return false; // change to true to simulate premium user
  }
}
