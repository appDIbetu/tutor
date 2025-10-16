class NotesTopic {
  final String id;
  final String name;
  final int pdfCount;
  final bool isPremium;
  final double price;
  final List<NotesPdf> pdfs;

  const NotesTopic({
    required this.id,
    required this.name,
    required this.pdfCount,
    required this.isPremium,
    required this.price,
    required this.pdfs,
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
      {
        'id': 'notes_1',
        'name': 'भौतिक विज्ञान नोट्स',
        'pdfCount': 3,
        'isPremium': false,
        'price': 0.0,
        'pdfs': [
          {
            'id': 'pdf_1_1',
            'name': 'यान्त्रिकी आधारभूत',
            'pageCount': 45,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_1_2',
            'name': 'ताप र ऊर्जा',
            'pageCount': 38,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_1_3',
            'name': 'विद्युत र चुम्बकत्व',
            'pageCount': 52,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_2',
        'name': 'रसायन विज्ञान नोट्स',
        'pdfCount': 2,
        'isPremium': true,
        'price': 25.0,
        'pdfs': [
          {
            'id': 'pdf_2_1',
            'name': 'अकार्बनिक रसायन',
            'pageCount': 67,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': true,
          },
          {
            'id': 'pdf_2_2',
            'name': 'कार्बनिक रसायन',
            'pageCount': 89,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': true,
          },
        ],
      },
      {
        'id': 'notes_3',
        'name': 'जीव विज्ञान नोट्स',
        'pdfCount': 4,
        'isPremium': false,
        'price': 0.0,
        'pdfs': [
          {
            'id': 'pdf_3_1',
            'name': 'कोशिका विज्ञान',
            'pageCount': 34,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_3_2',
            'name': 'आनुवंशिकी',
            'pageCount': 41,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_3_3',
            'name': 'परिस्थितिकी',
            'pageCount': 28,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': false,
          },
          {
            'id': 'pdf_3_4',
            'name': 'विकासवाद',
            'pageCount': 36,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': false,
          },
        ],
      },
      {
        'id': 'notes_4',
        'name': 'गणित नोट्स',
        'pdfCount': 1,
        'isPremium': true,
        'price': 15.0,
        'pdfs': [
          {
            'id': 'pdf_4_1',
            'name': 'क्यालकुलस र बीजगणित',
            'pageCount': 156,
            'downloadUrl':
                'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf',
            'isPremium': true,
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
