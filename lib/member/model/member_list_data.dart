class MemberListData {
  MemberListData({
    this.titleTxt = '',
    this.subTxt = "",
  });

  String titleTxt;
  String subTxt;

  static List<MemberListData> hotelList = <MemberListData>[
    MemberListData(
      titleTxt: 'devsunset',
      subTxt: 'Join Date : 22/10/01',
    ),
    MemberListData(
      titleTxt: 'guest',
      subTxt: 'Join Date : 22/10/01',
    ),
    MemberListData(
      titleTxt: 'testUser1',
      subTxt: 'Join Date : 22/10/01',
    ),
    MemberListData(
      titleTxt: 'testUser2',
      subTxt: 'Join Date : 22/10/01',
    ),
    MemberListData(
      titleTxt: 'testUser3',
      subTxt: 'Join Date : 22/10/01',
    ),
  ];
}
