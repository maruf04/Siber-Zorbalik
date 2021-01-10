import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'; // new
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';           // new
import 'src/authentication.dart';                  // new
import 'src/widgets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anti-Siber Zorba',
      theme: ThemeData(
       // canvasColor: Colors,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        children: <Widget>[
          Image.asset('assets/rsm2.gif'),
          SizedBox(height: 8),
          Header("Fırat üniversitesi covid-19 sebebiyle tatil oldu"),
          Row(
            children: [
              IconAndDetail(Icons.calendar_today, '14 Mart'),
              IconAndDetail(Icons.location_city, 'Elaziz'),
            ],
          ),

          Consumer<ApplicationState>(
            builder: (context, appState, _) => Authentication(
              email: appState.email,
              loginState: appState.loginState,
              startLoginFlow: appState.startLoginFlow,
              verifyEmail: appState.verifyEmail,
              signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
              cancelRegistration: appState.cancelRegistration,
              registerAccount: appState.registerAccount,
              signOut: appState.signOut,
            ),
          ),
          Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.blue,
          ),
          //Header("What we'll be doing"),
          /*Paragraph(
            'Join us for a day full of Firebase Workshops and Pizza!',
          ),*/
          // Modify from here
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.loginState == ApplicationLoginState.loggedIn) ...[
                 // Header('Anti-Siber Zorba'),
                  GuestBook(
                    addMessage: (String message) =>
                        appState.addMessageToGuestBook(message),//burayı kontrol et bura ile sansurlicez
                    messages: appState.guestBookMessages,
                  ),
                ]
              ],
            ),
          ),
          // To here.
        ],
      ),
    );
  }
}

String yeniCumle="";

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }
  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Giriş Yapmalısın');
    }
    _textControlEt(message);
    return FirebaseFirestore.instance.collection('guestbook').add({
      'text': yeniCumle,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser.displayName,
      'userId': FirebaseAuth.instance.currentUser.uid,
    });
  }

  Future<void> init() async {
    await Firebase.initializeApp();

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          snapshot.docs.forEach((document) {
            _guestBookMessages.add(
              GuestBookMessage(
                name: document.data()['name'],
                message: document.data()['text'],
              ),
            );
          });
          notifyListeners();
        });
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState;
  ApplicationLoginState get loginState => _loginState;

  String _email;
  String get email => _email;

  // Add from here
  StreamSubscription<QuerySnapshot> _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;
  // to here.

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void verifyEmail(
      String email,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      var methods =
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signInWithEmailAndPassword(
      String email,
      String password,
      void Function(FirebaseAuthException e) errorCallback,
      ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void registerAccount(String email, String displayName, String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user.updateProfile(displayName: displayName);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}

//yeni kod -------------------------------------------------------------------------------------------------------------------------------

 _textControlEt(String text1) {
  var cumle = text1.split(" ");
  var txt2=" ";
  var kKelime = [
    "abaza", "abazan", "ag", "ahmak", "am", "amar", "ambiti", "am biti", "amc", "amcuklama", "amcik", "amck", "amckl", "amcklama", "amcklaryla", "amckta", "amcktan", "amcuk", "am", "amına", "amına", "koy", "amuna koyarum", "amına koyayım", "amunakoyim", "koyyim", "sikem", "sokam", "amın feryadı",
    "amın oglu", "amoglu", "amın ", "amına", "amina", "amina ", "amina k", "aminako", "aminakoyarim", "amina koyarim", "amina koyayım", "amina koyayim", "aminakoyim", "aminda", "amindan", "amindayken", "amini", "aminiyarraaniskiim", "aminoglu", "amin oglu", "amiyum", "amk", "amkafa",
    "amk çocuğu", "amlarnzn", "amlı", "amm", "ammak", "ammna", "amn", "amna", "amnda", "amndaki", "amngtn", "amnn", "amona", "amq", "amsız", "amsiz", "amsz", "amteri", "amugaa", "amuğa","amuna", "ana", "anaaann", "anal", "analarn",
    "anam", "anamla", "anan", "anana", "anandan", "ananı", "ananı", "ananın", "ananın am", "ananın amı", "ananın dölü", "ananınki", "ananısikerim", "ananı sikerim", "ananısikeyim", "anan sikeyim", "anani", "ananin", "ananisikerim", "anani sikerim", "ananisikeyim", "anani sikeyim", "anann",
    "ananz", "anas", "anasını", "anasının am", "anası orospu", "anasi", "anasinin", "anay", "anayin", "angut", "anneni", "annenin", "annesiz", "anuna", "aptal", "aq", "a.q", "a.q.", "aq.", "ass", "atkafası", "atmık", "attırdığım", "attrrm",
    "auzlu", "avrat", "ayklarmalrmsikerim", "azdım", "azdır", "azdırıcı", "babaannesi kaşar", "babanı", "babanın", "babani", "babası pezevenk", "bacağına sıçayım", "bacına", "bacını", "bacının", "bacini", "bacn", "bacndan", "bacy", "bastard", "basur", "beyinsiz", "bızır", "bitch", "biting", "bok", "boka", "bokbok", "bokça",
    "bokhu","bokkkumu", "boklar", "boktan", "boku", "bokubokuna", "bokum", "bombok", "boner", "bosalmak", "boşalmak", "cenabet", "cibiliyetsiz", "cibilliyetini", "cibilliyetsiz", "cif", "cikar", "cim", "çük", "dalaksız", "dallama", "daltassak", "dalyarak", "dalyarrak", "dangalak", "dassagi",
    "diktim", "dildo", "dingil", "dingilini", "dinsiz", "dkerim", "domal", "domalan", "domaldı", "domaldın", "domalık", "domalıyor", "domalmak", "domalmış", "domalsın", "domalt", "domaltarak", "domaltıp", "domaltır", "domaltırım", "domaltip", "domaltmak", "dölü", "dönek",
    "düdük", "eben", "ebeni", "ebenin", "ebeninki", "ebleh", "ecdadını", "ecdadini", "embesil", "emi", "fahise", "fahişe", "feriştah", "ferre", "fuck", "fucker", "fuckin", "fucking", "gavad", "gavat", "geber", "geberik", "gebermek", "gebermiş", "gebertir", "gerızekalı", "gerizekalı", "gerizekali", "gerzek",
    "giberim", "giberler", "gibis", "gibiş", "gibmek", "gibtiler", "goddamn", "godoş", "godumun", "gotelek", "gotlalesi", "gotlu", "gotten", "gotundeki", "gotunden", "gotune", "gotunu", "gotveren", "goyiim", "goyum", "goyuyim", "goyyim", "göt", "göt deliği", "götelek", "göt herif", "götlalesi", "götlek",
    "götoğlanı", "göt oğlanı", "götoş", "götten", "götü", "götün", "götüne", "götünekoyim", "götüne koyim", "götünü", "götveren", "göt veren", "göt verir", "gtelek", "gtn", "gtnde", "gtnden", "gtne", "gtten", "gtveren", "hasiktir", "hassikome", "hassiktir", "has siktir", "hassittir",
    "haysiyetsiz","hayvan herif", "hoşafı", "hödük", "hsktr", "huur", "ıbnelık", "ibina", "ibine", "ibinenin", "ibne", "ibnedir", "ibneleri", "ibnelik", "ibnelri", "ibneni", "ibnenin", "ibnerator", "ibnesi", "idiot", "idiyot", "imansz", "ipne", "iserim", "işerim", "itoğlu it", "kafam girsin",
    "kafasız", "kafasiz", "kahpe", "kahpenin", "kahpenin feryadı", "kaka", "kaltak", "kancık", "kancik", "kappe", "karhane", "kaşar", "kavat", "kavatn", "kaypak", "kayyum", "kerane",
    "kerhane", "kerhanelerde", "kevase", "kevaşe", "kevvase", "koca göt", "koduğmun", "koduğmunun", "kodumun", "kodumunun", "koduumun", "koyarm", "koyayım", "koyiim", "koyiiym", "koyim", "koyum", "koyyim", "krar", "kukudaym", "laciye boyadım", "lavuk", "liboş", "madafaka", "mal", "malafat", "malak", "manyak", "mcik", "meme", "memelerini",
    "mezveleli", "minaamcık", "mincikliyim", "mna","monakkoluyum", "motherfucker", "mudik", "oc", "ocuu", "ocuun", "OÇ", "oç", "o. çocuğu", "oğlan", "oğlancı", "oğlu it", "orosbucocuu", "orospu", "orospucocugu", "orospu cocugu", "orospu çoc", "orospuçocuğu", "orospu çocuğu", "orospu çocuğudur", "orospu çocukları", "orospudur", "orospular", "orospunun",
    "orospunun evladı", "orospuydu", "orospuyuz", "orostoban", "orostopol", "orrospu", "oruspu", "oruspuçocuğu", "oruspu çocuğu", "osbir", "ossurduum", "ossurmak", "ossuruk", "osur", "osurduu", "osuruk", "osururum", "otuzbir", "öküz","öşex", "patlak zar", "penis", "pezevek", "pezeven", "pezeveng", "pezevengi", "pezevengin evladı",
    "pezevenk", "pezo", "pic", "pici", "picler", "piç", "piçin oğlu", "piç kurusu", "piçler", "pipi", "pipiş", "pisliktir", "porno", "pussy", "puşt", "puşttur", "rahminde", "revizyonist", "s1kerim", "s1kerm", "s1krm", "sakso", "saksofon", "salaak", "salak", "saxo", "sekis", "serefsiz", "sevgi koyarım", "sevişelim", "sexs",
    "sıçarım", "sıçtığım", "sıecem", "sicarsin", "sie", "sik", "sikdi", "sikdiğim", "sike", "sikecem", "sikem", "siken", "sikenin", "siker", "sikerim", "sikerler", "sikersin", "sikertir", "sikertmek", "sikesen", "sikesicenin", "sikey",
    "sikeydim", "sikeyim", "sikeym", "siki", "sikicem", "sikici", "sikien", "sikienler", "sikiiim", "sikiiimmm", "sikiim", "sikiir", "sikiirken", "sikik", "sikil", "sikildiini", "sikilesice", "sikilmi", "sikilmie", "sikilmis",
    "sikilmiş", "sikilsin", "sikim", "sikimde", "sikimden", "sikime", "sikimi", "sikimiin", "sikimin", "sikimle", "sikimsonik", "sikimtrak", "sikin", "sikinde", "sikinden", "sikine", "sikini", "sikip", "sikis", "sikisek", "sikisen", "sikish",
    "sikismis", "sikiş", "sikişen", "sikişme", "sikitiin", "sikiyim", "sikiym", "sikiyorum", "sikkim", "sikko", "sikleri", "sikleriii", "sikli", "sikm", "sikmek", "sikmem", "sikmiler", "sikmisligim", "siksem", "sikseydin", "sikseyidin", "siksin", "siksinbaya", "siksinler", "siksiz", "siksok", "siksz", "sikt", "sikti", "siktigimin", "siktigiminin", "siktiğim", "siktiğimin", "siktiğiminin",
    "siktii", "siktiim", "siktiimin", "siktiiminin", "siktiler", "siktim", "siktim", "siktimin", "siktiminin", "siktir", "siktir et", "siktirgit", "siktir git", "siktirir", "siktiririm", "siktiriyor", "siktir lan", "siktirolgit", "siktir ol git", "sittimin", "sittir", "skcem", "skecem", "skem", "sker", "skerim", "skerm", "skeyim", "skiim", "skik", "skim", "skime", "skmek", "sksin", "sksn", "sksz", "sktiimin", "sktrr", "skyim", "slaleni",
    "sokam", "sokarım", "sokarim", "sokarm", "sokarmkoduumun", "sokayım", "sokaym", "sokiim", "soktuğumunun", "sokuk", "sokum", "sokuş", "sokuyum", "soxum", "sulaleni", "sülaleni", "sülalenizi", "sürtük", "şerefsiz", "şıllık", "taaklarn", "taaklarna","tarrakimin", "tasak", "tassak", "taşak", "taşşak", "tipini s.k", "tipinizi s.keyim", "tiyniyat",
    "toplarm", "topsun", "totoş", "vajina", "vajinanı", "veled", "veledizina", "veled i zina", "verdiimin", "weled", "weledizina", "whore","xikeyim", "yaaraaa", "yalama", "yalarım", "yalarun", "yaraaam", "yarak","yaraksız", "yaraktr", "yaram", "yaraminbasi", "yaramn", "yararmorospunun", "yarra", "yarraaaa", "yarraak", "yarraam", "yarraamı", "yarragi", "yarragimi", "yarragina", "yarragindan", "yarragm", "yarrağ", "yarrağım", "yarrağımı",
    "yarraimin","yarrak", "yarram", "yarramin", "yarraminbaşı", "yarramn", "yarran","yarrana", "yarrrak", "yavak", "yavş", "yavsak","yavşak","yavşaktır", "yavuşak", "yılışık", "yilisik", "yogurtlayam", "yoğurtlayam", "yrrak", "zıkkımım", "zibidi", "zigsin", "zikeyim", "zikiiim", "zikiim", "zikik", "zikim", "ziksiiin", "ziksiin", "zulliyetini", "zviyetini"
  ];

  for (var i = 0; i < cumle.length; i++) {
    for (var j = 0; j < kKelime.length; j++) {
      if (cumle[i] == kKelime[j]) {
        var tt="";
        var tL=cumle[i].length;
        for(var k=0;k<tL;k++){
          tt=tt+"*";
        }
        cumle[i]=tt;
      }
    }
  }
  for (var i = 0; i < cumle.length; i++) {
    txt2 = txt2+" "+cumle[i];
  }
  yeniCumle=txt2.trim().toString();
}

//-------------------------------------------------------------------------------------------------------------------------------------

class GuestBookMessage {
  GuestBookMessage({@required this.name, @required this.message});
  final String name;
  String message;







}

class GuestBook extends StatefulWidget {
  GuestBook({@required this.addMessage, @required this.messages});
  final Future<void> Function(String message) addMessage;
  final List<GuestBookMessage> messages; // new
  //yeni kod



  @override
  _GuestBookState createState() => _GuestBookState();
}

class _GuestBookState extends State<GuestBook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();

  @override
  // Modify from here
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Bir mesaj yaz',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Devam etmek için Mesajınızı girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  StyledButton(
                    child: Row(
                      children: [
                        Icon(Icons.send),
                        SizedBox(width: 4),
                        Text('GÖNDER'),
                      ],
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        await widget.addMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Modify from here
          SizedBox(height: 8),
          for (var message in widget.messages)
            Paragraph('${message.name}: ${message.message}'),
          SizedBox(height: 8),
          // to here.
        ],
    );
  }
}
