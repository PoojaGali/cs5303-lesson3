enum PhotoSource {
  CAMERA,
  GALLERY,
}

class Profile {
  String? docId; //Firestore auto generated id
  late String email;
  late DateTime signUpDate;
  late String description;
  late String name;
  late String photoURL;
  late String photoFilename; // image at Cloud Storage

//key for firestore documents
  static const DESCRIPTION = 'description';
  static const PHOTO_FILENAME = 'photofilename';
  static const USER_EMAIL = 'user_email';
  static const SIGNUP_DATE = 'signup_date';
  static const NAME = 'name';
  static const PHOTO_URL = 'photoURL';

  Profile({
    this.docId,
    this.email = '',
    this.photoFilename = '',
    DateTime? signUpDate,
    this.description = '',
    this.name = '',
    this.photoURL = '',
  }) : this.signUpDate = signUpDate ?? DateTime.now();

  Profile.clone(Profile p) {
    this.docId = p.docId;
    this.email = p.email;
    this.signUpDate = p.signUpDate;
    this.description = p.description;
    this.photoFilename = p.photoFilename;
    this.name = p.name;
    this.photoURL = p.photoURL;
  }

  void assign(Profile p) {
    this.docId = p.docId;
    this.email = p.email;
    this.photoURL = p.photoURL;
    this.signUpDate = p.signUpDate;
    this.description = p.description;
    this.name = p.name;
    this.photoFilename = p.photoFilename;
  }

  Map<String, dynamic> toFirestoreDoc() {
    return <String, dynamic>{
      DESCRIPTION: this.description,
      SIGNUP_DATE: this.signUpDate,
      NAME: this.name,
      USER_EMAIL: this.email,
      PHOTO_FILENAME: this.photoFilename,
      PHOTO_URL: this.photoURL,
    };
  }

  static Profile fromFirestoreDoc(Map<String, dynamic> doc, String docId) {
    return Profile(
      docId: docId,
      email: doc[USER_EMAIL],
      name: doc[NAME],
      description: doc[DESCRIPTION],
      photoURL: doc[PHOTO_URL] ??= 'N/A',
      photoFilename: doc[PHOTO_FILENAME] ??= 'N/A',
      signUpDate: doc[SIGNUP_DATE] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[SIGNUP_DATE].millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }
}
