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

  // ===== أذكار إضافية من "حصن المسلم" حسب المواقف اليومية =====

  static List<ZikrItem> getWakingUpAzkar() {
    return [
      ZikrItem(
        id: 'w1',
        textAr: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ.',
        textEn: 'Praise be to Allah Who gave us life after having caused us to die.',
        repeat: 1,
        descriptionAr: 'يُقال عند الاستيقاظ من النوم.',
        descriptionEn: 'Recited upon waking up.',
      ),
    ];
  }

  static List<ZikrItem> getHomeAzkar() {
    return [
      ZikrItem(
        id: 'h1',
        textAr: 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا، ثُمَّ يُسَلِّمُ عَلَى أَهْلِهِ.',
        textEn: 'In the name of Allah we enter, and in the name of Allah we leave.',
        repeat: 1,
        descriptionAr: 'دعاء دخول المنزل.',
        descriptionEn: 'Supplication for entering the home.',
      ),
      ZikrItem(
        id: 'h2',
        textAr: 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ.',
        textEn: 'In the name of Allah, I place my trust in Allah.',
        repeat: 1,
        descriptionAr: 'دعاء الخروج من المنزل.',
        descriptionEn: 'Supplication for leaving the home.',
      ),
    ];
  }

  static List<ZikrItem> getMosqueAzkar() {
    return [
      ZikrItem(
        id: 'mq1',
        textAr: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ.',
        textEn: 'O Allah, open the gates of Your mercy for me.',
        repeat: 1,
        descriptionAr: 'دعاء دخول المسجد.',
        descriptionEn: 'Supplication for entering the mosque.',
      ),
      ZikrItem(
        id: 'mq2',
        textAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ.',
        textEn: 'O Allah, I ask You from Your bounty.',
        repeat: 1,
        descriptionAr: 'دعاء الخروج من المسجد.',
        descriptionEn: 'Supplication for leaving the mosque.',
      ),
    ];
  }

  static List<ZikrItem> getEatingAzkar() {
    return [
      ZikrItem(
        id: 'ea1',
        textAr: 'بِسْمِ اللَّهِ.',
        textEn: 'In the name of Allah.',
        repeat: 1,
        descriptionAr: 'يُقال قبل الطعام (فإن نسي في أوله قال: بسم الله في أوله وآخره).',
        descriptionEn: 'Said before eating.',
      ),
      ZikrItem(
        id: 'ea2',
        textAr: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا، وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ.',
        textEn: 'Praise be to Allah Who fed me this and provided it without any might from me.',
        repeat: 1,
        descriptionAr: 'يُقال بعد الانتهاء من الطعام.',
        descriptionEn: 'Said after finishing a meal.',
      ),
    ];
  }

  static List<ZikrItem> getTravelAzkar() {
    return [
      ZikrItem(
        id: 't1',
        textAr: 'اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ.',
        textEn: 'Allah is the greatest... Glory to Him Who has provided this for us.',
        repeat: 1,
        descriptionAr: 'دعاء ركوب وسيلة السفر.',
        descriptionEn: 'Supplication for boarding a vehicle for travel.',
      ),
    ];
  }

  static List<ZikrItem> getAfterPrayerAzkar() {
    return [
      ZikrItem(
        id: 'ap1',
        textAr: 'أَسْتَغْفِرُ اللَّهَ (ثلاثًا)، اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ.',
        textEn: 'I seek forgiveness from Allah (three times)...',
        repeat: 1,
        descriptionAr: 'يُقال عقب السلام من الصلاة المكتوبة.',
        descriptionEn: 'Recited right after the obligatory prayer.',
      ),
      ZikrItem(
        id: 'ap2',
        textAr: 'سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَاللَّهُ أَكْبَرُ.',
        textEn: 'Glory be to Allah, praise be to Allah, Allah is the greatest.',
        repeat: 33,
        descriptionAr: 'كل واحدة 33 مرة، وتُختم بلا إله إلا الله وحده لا شريك له تكملة المائة.',
        descriptionEn: 'Each recited 33 times after prayer.',
      ),
    ];
  }

  static List<ZikrItem> getDistressAzkar() {
    return [
      ZikrItem(
        id: 'd1',
        textAr: 'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ.',
        textEn: 'There is no god but Allah, the Mighty, the Forbearing...',
        repeat: 1,
        descriptionAr: 'دعاء الكرب والهم.',
        descriptionEn: 'Supplication for distress and anxiety.',
      ),
      ZikrItem(
        id: 'd2',
        textAr: 'اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ، وَأَصْلِحْ لِي شَأْنِي كُلَّهُ، لَا إِلَهَ إِلَّا أَنْتَ.',
        textEn: 'O Allah, it is Your mercy that I hope for...',
        repeat: 1,
        descriptionAr: 'دعاء عند الهمّ والغمّ.',
        descriptionEn: 'Supplication for worry and grief.',
      ),
    ];
  }

  static List<ZikrItem> getBathroomAzkar() {
    return [
      ZikrItem(
        id: 'bt1',
        textAr: 'بِسْمِ اللَّهِ، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ.',
        textEn: 'In the name of Allah. O Allah, I seek refuge in You from male and female devils.',
        repeat: 1,
        descriptionAr: 'يُقال عند دخول الخلاء (الحمّام).',
        descriptionEn: 'Said before entering the bathroom.',
      ),
      ZikrItem(
        id: 'bt2',
        textAr: 'غُفْرَانَكَ.',
        textEn: 'I ask You for forgiveness.',
        repeat: 1,
        descriptionAr: 'يُقال عند الخروج من الخلاء.',
        descriptionEn: 'Said after leaving the bathroom.',
      ),
    ];
  }

  static List<ZikrItem> getDressingAzkar() {
    return [
      ZikrItem(
        id: 'dr1',
        textAr: 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا (الثَّوْبَ) وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ.',
        textEn: 'Praise be to Allah Who has clothed me with this garment and provided it for me.',
        repeat: 1,
        descriptionAr: 'يُقال عند لبس الثوب الجديد.',
        descriptionEn: 'Said when wearing a new garment.',
      ),
    ];
  }

  static List<ZikrItem> getSneezeAzkar() {
    return [
      ZikrItem(
        id: 'sn1',
        textAr: 'الْحَمْدُ لِلَّهِ.',
        textEn: 'Praise be to Allah.',
        repeat: 1,
        descriptionAr: 'يقولها العاطس، ويردّ عليه من سمعه: يَرْحَمُكَ اللَّهُ، فيردّ عليه العاطس: يَهْدِيكُمُ اللَّهُ وَيُصْلِحُ بَالَكُمْ.',
        descriptionEn: 'Said by the one who sneezes; others reply "Yarhamuk Allah".',
      ),
    ];
  }

  static List<ZikrItem> getAngerAzkar() {
    return [
      ZikrItem(
        id: 'an1',
        textAr: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ.',
        textEn: 'I seek refuge in Allah from the accursed Satan.',
        repeat: 1,
        descriptionAr: 'يُقال عند الغضب.',
        descriptionEn: 'Said when feeling angry.',
      ),
    ];
  }

  static List<ZikrItem> getRainAzkar() {
    return [
      ZikrItem(
        id: 'rn1',
        textAr: 'اللَّهُمَّ صَيِّبًا نَافِعًا.',
        textEn: 'O Allah, (bring) beneficial rain clouds.',
        repeat: 1,
        descriptionAr: 'يُقال عند نزول المطر.',
        descriptionEn: 'Said when it rains.',
      ),
      ZikrItem(
        id: 'rn2',
        textAr: 'سُبْحَانَ الَّذِي يُسَبِّحُ الرَّعْدُ بِحَمْدِهِ وَالْمَلَائِكَةُ مِنْ خِيفَتِهِ.',
        textEn: 'Glory to Him Whom thunder and the angels glorify due to fear of Him.',
        repeat: 1,
        descriptionAr: 'يُقال عند سماع الرعد.',
        descriptionEn: 'Said upon hearing thunder.',
      ),
    ];
  }

  static List<ZikrItem> getSicknessAzkar() {
    return [
      ZikrItem(
        id: 'sk1',
        textAr: 'أَذْهِبِ الْبَاسَ رَبَّ النَّاسِ، وَاشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا.',
        textEn: 'Remove the difficulty, Lord of mankind, and grant healing, for You are the Healer.',
        repeat: 1,
        descriptionAr: 'دعاء عيادة المريض (يقوله العائد للمريض).',
        descriptionEn: 'Supplication said when visiting a sick person.',
      ),
      ZikrItem(
        id: 'sk2',
        textAr: 'لَا بَأْسَ، طَهُورٌ إِنْ شَاءَ اللَّهُ.',
        textEn: 'No harm, it is a purification, Allah willing.',
        repeat: 1,
        descriptionAr: 'يُقال للمريض تطييبًا لخاطره.',
        descriptionEn: 'Said to comfort the sick person.',
      ),
    ];
  }

  static List<ZikrItem> getReliefAzkar() {
    return [
      ZikrItem(
        id: 'rl1',
        textAr: 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ.',
        textEn: 'O Allah, suffice me with what You have permitted instead of what You have forbidden.',
        repeat: 1,
        descriptionAr: 'دعاء قضاء الدَّين وتفريج الهمّ.',
        descriptionEn: 'Supplication for settling debt and relieving worry.',
      ),
    ];
  }

  static List<ZikrItem> getMarketAzkar() {
    return [
      ZikrItem(
        id: 'mk1',
        textAr: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ وَهُوَ حَيٌّ لَا يَمُوتُ، بِيَدِهِ الْخَيْرُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
        textEn: 'There is no god but Allah alone, with no partner. His is the dominion and praise.',
        repeat: 1,
        descriptionAr: 'دعاء دخول السوق.',
        descriptionEn: 'Supplication for entering the marketplace.',
      ),
    ];
  }

  static List<ZikrItem> getThanksReplyAzkar() {
    return [
      ZikrItem(
        id: 'tr1',
        textAr: 'جَزَاكَ اللَّهُ خَيْرًا.',
        textEn: 'May Allah reward you with good.',
        repeat: 1,
        descriptionAr: 'دعاء لمن أسدى إليك معروفًا.',
        descriptionEn: 'Said to someone who has done you a favor.',
      ),
    ];
  }

  static List<ZikrItem> getNewbornAzkar() {
    return [
      ZikrItem(
        id: 'nb1',
        textAr: 'بَارَكَ اللَّهُ لَكَ فِي الْمَوْهُوبِ لَكَ، وَشَكَرْتَ الْوَاهِبَ، وَبَلَغَ أَشُدَّهُ، وَرُزِقْتَ بِرَّهُ.',
        textEn: 'May Allah bless you with His gift, and may you be grateful to the Giver.',
        repeat: 1,
        descriptionAr: 'دعاء تهنئة من رُزق بمولود.',
        descriptionEn: 'Supplication for congratulating new parents.',
      ),
    ];
  }

  static List<ZikrItem> getCondolenceAzkar() {
    return [
      ZikrItem(
        id: 'cd1',
        textAr: 'إِنَّ لِلَّهِ مَا أَخَذَ، وَلَهُ مَا أَعْطَى، وَكُلُّ شَيْءٍ عِنْدَهُ بِأَجَلٍ مُسَمًّى، فَلْتَصْبِرْ وَلْتَحْتَسِبْ.',
        textEn: 'To Allah belongs what He takes and what He gives, everything is written with an appointed term.',
        repeat: 1,
        descriptionAr: 'دعاء التعزية في الميت.',
        descriptionEn: 'Supplication for offering condolences.',
      ),
      ZikrItem(
        id: 'cd2',
        textAr: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي وَأَخْلِفْ لِي خَيْرًا مِنْهَا.',
        textEn: 'To Allah we belong and to Him we shall return. O Allah, reward me for my affliction.',
        repeat: 1,
        descriptionAr: 'يقوله المصاب نفسه عند المصيبة.',
        descriptionEn: 'Said by the one who has suffered a loss.',
      ),
    ];
  }

  static List<ZikrItem> getMarriageAzkar() {
    return [
      ZikrItem(
        id: 'mr1',
        textAr: 'بَارَكَ اللَّهُ لَكَ، وَبَارَكَ عَلَيْكَ، وَجَمَعَ بَيْنَكُمَا فِي خَيْرٍ.',
        textEn: 'May Allah bless you, and bless for you, and join you together in goodness.',
        repeat: 1,
        descriptionAr: 'دعاء تهنئة المتزوّج.',
        descriptionEn: 'Supplication for congratulating a newlywed.',
      ),
      ZikrItem(
        id: 'mr2',
        textAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا وَخَيْرَ مَا جَبَلْتَهَا عَلَيْهِ، وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ مَا جَبَلْتَهَا عَلَيْهِ.',
        textEn: 'O Allah, I ask You for the good in her and the good You have created her with.',
        repeat: 1,
        descriptionAr: 'دعاء الزوج إذا تزوّج (يضع يده على ناصية زوجته).',
        descriptionEn: 'Supplication said by the husband on his wedding night.',
      ),
    ];
  }

  static List<ZikrItem> getIftarAzkar() {
    return [
      ZikrItem(
        id: 'if1',
        textAr: 'ذَهَبَ الظَّمَأُ، وَابْتَلَّتِ الْعُرُوقُ، وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ.',
        textEn: 'The thirst has gone, the veins are moistened, and the reward is confirmed, Allah willing.',
        repeat: 1,
        descriptionAr: 'دعاء الإفطار للصائم.',
        descriptionEn: 'Supplication said when breaking the fast.',
      ),
    ];
  }

  static List<ZikrItem> getWindAzkar() {
    return [
      ZikrItem(
        id: 'wd1',
        textAr: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا وَخَيْرَ مَا فِيهَا وَخَيْرَ مَا أُرْسِلَتْ بِهِ، وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ مَا فِيهَا وَشَرِّ مَا أُرْسِلَتْ بِهِ.',
        textEn: 'O Allah, I ask You for its good and seek refuge in You from its evil.',
        repeat: 1,
        descriptionAr: 'دعاء عند هبوب الريح.',
        descriptionEn: 'Supplication said when the wind blows.',
      ),
    ];
  }

  static List<ZikrItem> getFearOfShirkAzkar() {
    return [
      ZikrItem(
        id: 'fs1',
        textAr: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أُشْرِكَ بِكَ وَأَنَا أَعْلَمُ، وَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُ.',
        textEn: 'O Allah, I seek refuge in You from knowingly associating partners with You.',
        repeat: 1,
        descriptionAr: 'دعاء الخوف من الشرك الخفي.',
        descriptionEn: 'Supplication seeking refuge from hidden association with Allah.',
      ),
    ];
  }

  static List<ZikrItem> getRuqyahAzkar() {
    return [
      ZikrItem(
        id: 'rq1',
        textAr: 'أُعِيذُكَ بِاللَّهِ الْوَاحِدِ الْأَحَدِ الصَّمَدِ الَّذِي لَمْ يَلِدْ وَلَمْ يُولَدْ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ، مِنْ شَرِّ كُلِّ حَاسِدٍ وَكُلِّ ذِي عَيْنٍ.',
        textEn: 'I seek refuge for you in Allah, the One, from the evil of every envier and every eye.',
        repeat: 1,
        descriptionAr: 'رقية من العين والحسد.',
        descriptionEn: 'Ruqyah against the evil eye and envy.',
      ),
      ZikrItem(
        id: 'rq2',
        textAr: 'بِسْمِ اللَّهِ أَرْقِيكَ، مِنْ كُلِّ شَيْءٍ يُؤْذِيكَ، مِنْ شَرِّ كُلِّ نَفْسٍ أَوْ عَيْنِ حَاسِدٍ، اللَّهُ يَشْفِيكَ، بِسْمِ اللَّهِ أَرْقِيكَ.',
        textEn: 'In the name of Allah I perform ruqyah for you, from all that harms you.',
        repeat: 1,
        descriptionAr: 'رقية عامة للمريض.',
        descriptionEn: 'General ruqyah for the sick.',
      ),
    ];
  }

  // ===== دفعة إضافية: أذكار الصلاة والمناسك والمواسم =====

  static List<ZikrItem> getAdhanResponseAzkar() {
    return [
      ZikrItem(
        id: 'adr1',
        textAr: 'يقول السامع مثل ما يقول المؤذن، إلا في "حَيَّ عَلَى الصَّلَاةِ" و"حَيَّ عَلَى الْفَلَاحِ" فيقول: لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ.',
        textEn: 'Repeat what the muadhin says, except at "Hayya alas-salah/al-falah" where you say "La hawla wala quwwata illa billah".',
        repeat: 1,
        descriptionAr: 'إجابة المؤذن أثناء الأذان.',
        descriptionEn: 'Responding to the adhan.',
      ),
      ZikrItem(
        id: 'adr2',
        textAr: 'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ.',
        textEn: 'O Allah, Lord of this perfect call and established prayer, grant Muhammad the intercession and favor.',
        repeat: 1,
        descriptionAr: 'دعاء بعد الفراغ من إجابة الأذان.',
        descriptionEn: 'Supplication said after the adhan finishes.',
      ),
    ];
  }

  static List<ZikrItem> getPrayerMovementsAzkar() {
    return [
      ZikrItem(
        id: 'pm1',
        textAr: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ، وَتَعَالَى جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ.',
        textEn: 'Glory and praise be to You, O Allah. Blessed is Your name, and exalted is Your majesty.',
        repeat: 1,
        descriptionAr: 'دعاء الاستفتاح، يُقال بعد تكبيرة الإحرام.',
        descriptionEn: 'Opening supplication of the prayer.',
      ),
      ZikrItem(
        id: 'pm2',
        textAr: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ.',
        textEn: 'Glory be to my Lord, the Most Great.',
        repeat: 3,
        descriptionAr: 'يُقال في الركوع.',
        descriptionEn: 'Said while bowing (ruku).',
      ),
      ZikrItem(
        id: 'pm3',
        textAr: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ، رَبَّنَا وَلَكَ الْحَمْدُ.',
        textEn: 'Allah hears whoever praises Him. Our Lord, to You is the praise.',
        repeat: 1,
        descriptionAr: 'يُقال عند الرفع من الركوع.',
        descriptionEn: 'Said when rising from ruku.',
      ),
      ZikrItem(
        id: 'pm4',
        textAr: 'سُبْحَانَ رَبِّيَ الْأَعْلَى.',
        textEn: 'Glory be to my Lord, the Most High.',
        repeat: 3,
        descriptionAr: 'يُقال في السجود.',
        descriptionEn: 'Said while prostrating (sujud).',
      ),
      ZikrItem(
        id: 'pm5',
        textAr: 'رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي.',
        textEn: 'My Lord, forgive me. My Lord, forgive me.',
        repeat: 1,
        descriptionAr: 'يُقال في الجلوس بين السجدتين.',
        descriptionEn: 'Said while sitting between the two prostrations.',
      ),
      ZikrItem(
        id: 'pm6',
        textAr: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ، السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ.',
        textEn: 'All greetings, prayers, and good deeds are for Allah. Peace be upon you, O Prophet...',
        repeat: 1,
        descriptionAr: 'التشهد.',
        descriptionEn: 'The tashahhud.',
      ),
      ZikrItem(
        id: 'pm7',
        textAr: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ. اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ.',
        textEn: 'O Allah, send prayers upon Muhammad and the family of Muhammad, as You sent prayers upon Ibrahim...',
        repeat: 1,
        descriptionAr: 'الصلاة الإبراهيمية بعد التشهد.',
        descriptionEn: 'The Ibrahimic prayer said after the tashahhud.',
      ),
    ];
  }

  static List<ZikrItem> getIstikharahAzkar() {
    return [
      ZikrItem(
        id: 'ik1',
        textAr: 'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ، وَتَعْلَمُ وَلَا أَعْلَمُ، وَأَنْتَ عَلَّامُ الْغُيُوبِ، اللَّهُمَّ إِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ (وتُسمّى حاجتك) خَيْرٌ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي، فَاقْدُرْهُ لِي وَيَسِّرْهُ لِي، ثُمَّ بَارِكْ لِي فِيهِ، وَإِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ شَرٌّ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي، فَاصْرِفْهُ عَنِّي وَاصْرِفْنِي عَنْهُ، وَاقْدُرْ لِيَ الْخَيْرَ حَيْثُ كَانَ، ثُمَّ أَرْضِنِي بِهِ.',
        textEn: 'O Allah, I seek Your counsel by Your knowledge, and I seek ability from You by Your power...',
        repeat: 1,
        descriptionAr: 'دعاء صلاة الاستخارة، يُقال بعد ركعتين نافلة.',
        descriptionEn: 'The prayer of guidance (istikharah), said after two voluntary rak\'ahs.',
      ),
    ];
  }

  static List<ZikrItem> getQunootAzkar() {
    return [
      ZikrItem(
        id: 'qn1',
        textAr: 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ، وَبَارِكْ لِي فِيمَا أَعْطَيْتَ، وَقِنِي شَرَّ مَا قَضَيْتَ، فَإِنَّكَ تَقْضِي وَلَا يُقْضَى عَلَيْكَ، وَإِنَّهُ لَا يَذِلُّ مَنْ وَالَيْتَ، تَبَارَكْتَ رَبَّنَا وَتَعَالَيْتَ.',
        textEn: 'O Allah, guide me among those You have guided, grant me health among those You have granted health...',
        repeat: 1,
        descriptionAr: 'دعاء القنوت في صلاة الوتر.',
        descriptionEn: 'The supplication of qunoot in the witr prayer.',
      ),
    ];
  }

  static List<ZikrItem> getNewMoonAzkar() {
    return [
      ZikrItem(
        id: 'nm1',
        textAr: 'اللَّهُ أَكْبَرُ، اللَّهُمَّ أَهِلَّهُ عَلَيْنَا بِالْأَمْنِ وَالْإِيمَانِ، وَالسَّلَامَةِ وَالْإِسْلَامِ، رَبِّي وَرَبُّكَ اللَّهُ.',
        textEn: 'Allah is the greatest. O Allah, bring this new moon over us with security and faith.',
        repeat: 1,
        descriptionAr: 'دعاء رؤية الهلال.',
        descriptionEn: 'Supplication upon sighting the new moon.',
      ),
    ];
  }

  static List<ZikrItem> getTalbiyahAzkar() {
    return [
      ZikrItem(
        id: 'tl1',
        textAr: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ.',
        textEn: 'Here I am, O Allah, here I am. Here I am, You have no partner, here I am.',
        repeat: 1,
        descriptionAr: 'تلبية الحج والعمرة.',
        descriptionEn: 'The talbiyah recited during Hajj and Umrah.',
      ),
    ];
  }

  static List<ZikrItem> getIstisqaAzkar() {
    return [
      ZikrItem(
        id: 'is1',
        textAr: 'اللَّهُمَّ اسْقِنَا غَيْثًا مُغِيثًا مَرِيئًا مَرِيعًا، نَافِعًا غَيْرَ ضَارٍّ، عَاجِلًا غَيْرَ آجِلٍ.',
        textEn: 'O Allah, send us rain that brings relief, wholesome and abundant, beneficial and not harmful.',
        repeat: 1,
        descriptionAr: 'دعاء الاستسقاء (طلب نزول المطر عند الجفاف).',
        descriptionEn: 'Supplication for rain during drought.',
      ),
    ];
  }

  static List<ZikrItem> getEidGreetingAzkar() {
    return [
      ZikrItem(
        id: 'eg1',
        textAr: 'تَقَبَّلَ اللَّهُ مِنَّا وَمِنْكُمْ.',
        textEn: 'May Allah accept (good deeds) from us and from you.',
        repeat: 1,
        descriptionAr: 'تهنئة العيد بين المسلمين.',
        descriptionEn: 'The Eid greeting exchanged among Muslims.',
      ),
    ];
  }

  static List<ZikrItem> getSeeingAfflictedAzkar() {
    return [
      ZikrItem(
        id: 'sa1',
        textAr: 'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي مِمَّا ابْتَلَاكَ بِهِ، وَفَضَّلَنِي عَلَى كَثِيرٍ مِمَّنْ خَلَقَ تَفْضِيلًا.',
        textEn: 'Praise be to Allah Who has spared me from what He has afflicted you with.',
        repeat: 1,
        descriptionAr: 'يُقال سرًّا (من غير أن يسمعه المبتلى) عند رؤية شخص مصاب ببلاء.',
        descriptionEn: 'Said quietly (not aloud) upon seeing someone afflicted with a hardship.',
      ),
    ];
  }

  static List<ZikrItem> getNightFearAzkar() {
    return [
      ZikrItem(
        id: 'nf1',
        textAr: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ غَضَبِهِ وَعِقَابِهِ، وَشَرِّ عِبَادِهِ، وَمِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَنْ يَحْضُرُونِ.',
        textEn: 'I seek refuge in the perfect words of Allah from His anger and punishment.',
        repeat: 1,
        descriptionAr: 'دعاء الفزع أو الأرق في النوم.',
        descriptionEn: 'Supplication for fear or restlessness during sleep.',
      ),
    ];
  }
}


