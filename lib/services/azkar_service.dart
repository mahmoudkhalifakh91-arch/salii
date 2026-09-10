import '../models/azkar_model.dart';

class AzkarService {
  static List<ZikrItem> getMorningAzkar() {
    return [
      ZikrItem(
        id: 'm1',
        textAr: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
        textEn: 'We have entered a new day and with it all dominion belongs to Allah. Praise is to Allah.',
        repeat: 1,
        descriptionAr: 'يُقال مرة واحدة في الصباح لانشراح الصدر والحفظ.',
        descriptionEn: 'To be recited once in the morning for peace and protection.',
      ),
      ZikrItem(
        id: 'm2',
        textAr: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ.',
        textEn: 'O Allah, by You we enter the morning and by You we enter the evening.',
        repeat: 1,
        descriptionAr: 'من أذكار الصباح المأثورة.',
        descriptionEn: 'To be recited once in the morning.',
      ),
      ZikrItem(
        id: 'm3',
        textAr: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ.',
        textEn: 'Glory be to Allah and Praise be to Him.',
        repeat: 100,
        descriptionAr: 'حُطّت خطاياه وإن كانت مثل زبد البحر.',
        descriptionEn: 'Sins are forgiven even if they are like the foam of the sea.',
      ),
      ZikrItem(
        id: 'm4',
        textAr: 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
        textEn: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
        repeat: 3,
        descriptionAr: 'حماية من كل مكروه وسوء.',
        descriptionEn: 'Protects from any harm.',
      ),
      ZikrItem(
        id: 'm5',
        textAr: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.',
        textEn: 'In the name of Allah with whose Name nothing on earth or in heaven can cause harm.',
        repeat: 3,
        descriptionAr: 'لم يضره شيء في يومه.',
        descriptionEn: 'No harm shall touch whoever recites it 3 times.',
      ),
    ];
  }

  static List<ZikrItem> getEveningAzkar() {
    return [
      ZikrItem(
        id: 'e1',
        textAr: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
        textEn: 'We have entered the evening and dominion belongs to Allah.',
        repeat: 1,
        descriptionAr: 'يُقال عند دخول المساء لحفظ المسلم.',
        descriptionEn: 'Recited at evening for protection.',
      ),
      ZikrItem(
        id: 'e2',
        textAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ.',
        textEn: 'O Allah, I ask You for pardon and well-being in this life and the next.',
        repeat: 1,
        descriptionAr: 'سؤال العافية والسلامة في الدين والبدن.',
        descriptionEn: 'Asking for protection and well-being.',
      ),
      ZikrItem(
        id: 'e3',
        textAr: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ.',
        textEn: 'I seek forgiveness from Allah and repent to Him.',
        repeat: 100,
        descriptionAr: 'تفريج الهموم وزيادة الرزق.',
        descriptionEn: 'Relieves stress and brings blessings.',
      ),
    ];
  }

  static List<ZikrItem> getSleepAzkar() {
    return [
      ZikrItem(
        id: 's1',
        textAr: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ.',
        textEn: 'In Your name my Lord I lie down and in Your name I rise.',
        repeat: 1,
        descriptionAr: 'يُقال قبل النوم مباشرة.',
        descriptionEn: 'Recited right before sleeping.',
      ),
      ZikrItem(
        id: 's2',
        textAr: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ.',
        textEn: 'O Allah, save me from Your punishment on the Day You resurrect Your slaves.',
        repeat: 3,
        descriptionAr: 'ثلاث مرات مع وضع اليد اليمنى تحت الخد الأيمن.',
        descriptionEn: 'Recited 3 times placing right hand under right cheek.',
      ),
    ];
  }
}
