import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:newton_particles/newton_particles.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spoplusplusfy/Classes/song.dart';
import 'package:spoplusplusfy/Pages/search_page.dart';

import '../Classes/person.dart';
import '../Utilities/api_service.dart';


const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
// Define the regex pattern for username validation
const String usernamePattern = r'^[a-zA-Z0-9_-]{3,32}$';

// Define the regex pattern for password validation
const String passwordPattern = r'^.{8,32}$';

const String goldPlay = 'assets/icons/music_play_gold.svg';
const String blackPlay = 'assets/icons/music_play_black.svg';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<StatefulWidget> createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  int _selectedIdx = 0;
  bool _buttonPressed = false;
  bool _goodEmail = false;
  bool _goodUsername = false;
  bool _goodPassword = false;
  bool _goodConfirm = false;
  bool _goodCode = false;
  bool _goodBio = false;
  static int _requestVerification = 0;
  String _usernamePrompt = 'What should we call you?';
  String _passwordPrompt = 'Password should be 8-16 digits long';
  String _passwordConfirmPrompt = 'Please enter again your password';
  String _emailPrompt = 'Please enter your email';
  String _emailVerificationPrompt = 'Enter the verification code';
  String _buttonText = 'Send code';
  String _bioPrompt = 'Introduce yourself here!';
  late NavigationBar _navigationBar;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
  TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final PageController _controller = PageController();
  late Timer _emailTimer;
  int _countdownDuration = 60;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late double _screenDiagonal;
  String iconPlay = goldPlay;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_testEmail);
    _verificationController.addListener(_testVerification);
    _usernameController.addListener(_testUsername);
    _passwordController.addListener(_testPassword);
    _passwordConfirmController.addListener(_testPasswordConfirm);
    _bioController.addListener(_testBio);
    _requestVerification = 0;
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _screenDiagonal =
          sqrt(size.width * size.width + size.height * size.height);
      setState(() {
        _animation = Tween<double>(begin: 0, end: _screenDiagonal)
            .animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.ease,
        ));
      });
    });
  }

  // TODO: Request the correct verification code
  bool verify(String s) {
    if (_requestVerification >= 10) {
      setState(() {
        _emailVerificationPrompt =
            'You\'ve entered the code too much times, tap to resend';
      });
      return false;
    }
    _requestVerification += 1;
    //request = request();
    //return s == request;
    // TODO: return the result instead of true
    return true;
  }

  void _testEmail() {
    String query = _emailController.text;
    setState(() {
      bool suc = RegExp(emailPattern).hasMatch(query);
      if (suc) {
        _emailPrompt = '';
      } else {
        _emailPrompt = 'Please enter a valid address';
      }
      _goodEmail = suc;
    });
  }

  void _testVerification() {
    String query = _verificationController.text;
    if (query.length != 6) {
      setState(() {
        _goodCode = false;
        _emailVerificationPrompt = 'Verification code is invalid';
        return;
      });
    } else {
      setState(() {
        bool suc = verify(query);
        if (suc) {
          _emailVerificationPrompt = '';
        } else if (_requestVerification < 10) {
          _emailVerificationPrompt = 'Verification code is invalid';
        }
        _goodCode = suc;
      });
    }
  }

  void _testUsername() {
    String query = _usernameController.text;
    setState(() {
      bool suc = RegExp(usernamePattern).hasMatch(query);
      if (suc) {
        _usernamePrompt = '';
      } else if (query.length < 4) {
        _usernamePrompt = 'Username too short';
      } else if (query.length > 32) {
        _usernamePrompt = 'Username too long';
      } else {
        _usernamePrompt =
        'Username should only contains letters, numbers, \'-\' or \'_\'';
      }
      _goodUsername = suc;
    });
  }

  void _testPassword() {
    String query = _passwordController.text;
    setState(() {
      bool suc = RegExp(passwordPattern).hasMatch(query);
      if (suc) {
        _passwordPrompt = '';
      } else if (query.length < 8 && query.isNotEmpty)
        _passwordPrompt = 'Password too short';
      else if (query.isNotEmpty) _passwordPrompt = 'Password too long';
      _goodPassword = suc;
    });
  }

  void _testPasswordConfirm() {
    String check = _passwordController.text;
    String query = _passwordConfirmController.text;
    setState(() {
      bool suc = check == query;
      if (suc) {
        _passwordConfirmPrompt = '';
      } else {
        _passwordConfirmPrompt = 'Password not same';
      }
      _goodConfirm = suc;
    });
  }

  void _testBio() {
    String query = _bioController.text;
    setState(() {
      bool suc = query.length <= 250;
      if (suc) {
        _bioPrompt = '';
      } else {
        _bioPrompt = 'Maximum length is 250 characters';
      }
      _goodBio = suc;
    });
  }

  @override
  Widget build(BuildContext context) {
    _navigationBar = _buildNavigationBar();
    return PageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [_emailPage(), _userPage(), _personalInfoPage(), _finalPage()],
    );
  }

  NavigationBar _buildNavigationBar() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return NavigationBar(
      height: 50,
      backgroundColor: primaryColor,
      selectedIndex: _selectedIdx,
      destinations: [
        NavigationDestination(
            selectedIcon: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: secondaryColor),
              onPressed: () {
              },
              child: Text(
                'Username & Password',
                style: TextStyle(
                    color: primaryColor,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600),
              ),
            ),
            icon: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(width: 2.0, color: secondaryColor),
              ),
              onPressed: () {
              },
              child: Text(
                'Username & Password',
                style: TextStyle(
                    color: secondaryColor,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600),
              ),
            ),
            label: ''),
        NavigationDestination(
            selectedIcon: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: secondaryColor),
              onPressed: () {
                if (!(_goodEmail &&
                    _goodCode &&
                    _goodUsername &&
                    _goodConfirm &&
                    _goodPassword)) return;
                _selectedIdx = 1;
                _controller.animateToPage(_selectedIdx + 1,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease);
                setState(() {});
              },
              child: Text(
                'Personal Information',
                style:
                    TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            icon: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(width: 2.0, color: secondaryColor),
              ),
              onPressed: () {
              },
              child: Text('Personal Information',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: secondaryColor,
                  )),
            ),
            label: '')
      ],
    );
  }

  Column _typingField(String fieldName, bool test, String hintText,
      TextEditingController? controller, String iconPath) {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(fieldName,
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  )),
            ),
          ],
        ),
        Container(
            height: 50,
            margin: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
            ),
            child: TextField(
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: controller,
              style: TextStyle(color: secondaryColor, decorationThickness: 0),
              decoration: InputDecoration(
                filled: false,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                contentPadding: const EdgeInsets.all(15),
                labelText: hintText,
                labelStyle: TextStyle(color: secondaryColor, fontSize: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter:
                        ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                  ),
                ),
                suffixIcon: test
                    ? SizedBox(
                  width: 50,
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(6, 12, 12, 12),
                          child: SvgPicture.asset(
                                  'assets/icons/checkmark_gold.svg',
                                  colorFilter: ColorFilter.mode(
                                      secondaryColor, BlendMode.srcIn),
                                ),
                        ),
                      ],
                    ),
                  ),
                )
                    : null,
              ),
            )),
      ],
    );
  }

  Column _multilineField(String fieldName, bool test, String hintText,
      TextEditingController? controller, String iconPath) {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(fieldName,
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  )),
            ),
          ],
        ),
        Container(
            height: 200,
            margin: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
            ),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: controller,
              style: TextStyle(color: secondaryColor, decorationThickness: 0),
              decoration: InputDecoration(
                filled: false,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                contentPadding: const EdgeInsets.all(15),
                labelText: hintText,
                labelStyle: TextStyle(color: secondaryColor, fontSize: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter:
                        ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                  ),
                ),
                suffixIcon: test
                    ? SizedBox(
                  width: 50,
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(6, 12, 12, 12),
                          child: SvgPicture.asset(
                                  'assets/icons/checkmark_gold.svg',
                                  colorFilter: ColorFilter.mode(
                                      secondaryColor, BlendMode.srcIn),
                                ),
                        ),
                      ],
                    ),
                  ),
                )
                    : null,
              ),
            )),
      ],
    );
  }

  void _showError(var response) {
    showDialog(context: context, builder: (context) {
      var errorType = jsonDecode(response.body).keys.toList()[0];
      if (errorType.runtimeType != String) {
        errorType = errorType[0];
      }
      var errorDialog = jsonDecode(response.body).values.toList()[0];
      if (errorDialog.runtimeType == List) {
        errorDialog = errorDialog[0];
      }
      return AlertDialog(
          title: Text(errorType),
          content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(errorDialog),
                ],)));
    });
  }

  Scaffold _userPage() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    var effectColor = Theme.of(context).canvasColor;
    return Scaffold(
      backgroundColor: primaryColor,
      body: ListView(children: [
        Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Newton(
                activeEffects: [
                  RainEffect(
                    particleConfiguration: ParticleConfiguration(
                      shape: CircleShape(),
                      size: const Size(5, 5),
                      color: SingleParticleColor(color: effectColor),
                    ),
                    effectConfiguration: const EffectConfiguration(),
                  )
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 7,
                ),
                _navigationBar,
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                ),
                _typingField('Username', _goodUsername, _usernamePrompt,
                    _usernameController, 'assets/icons/user_gold.svg'),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 30,
                ),
                _typingField('Password', _goodPassword, _passwordPrompt,
                    _passwordController, 'assets/icons/key_gold.svg'),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 30,
                ),
                Visibility(
                  visible: _goodPassword,
                  child: _typingField(
                      'Confirm Password',
                      _goodConfirm,
                      _passwordConfirmPrompt,
                      _passwordConfirmController,
                      'assets/icons/key_gold.svg'),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _controller.previousPage(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.ease);
                      },
                      style: OutlinedButton.styleFrom(
                        fixedSize: const Size(65, 65),
                        padding: const EdgeInsets.all(10),
                        side: BorderSide(width: 2.0, color: secondaryColor),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/left_arrow_gold.svg',
                        colorFilter:
                            ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                      ),
                    ),
                    Visibility(
                      visible: _goodUsername &&
                          _goodPassword &&
                          _goodConfirm &&
                          _goodEmail &&
                          _goodCode,
                      child: OutlinedButton(
                        onPressed: () async {
                          try {
                            var response = await http.post(
                                Uri.parse('http://$fhlIP/api/auth/register'),
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                },
                                body: jsonEncode({
                                  'email' : _emailController.text,
                                  'password' : _passwordController.text,
                                  'username' : _usernameController.text,
                                })
                            );
                            if (response.statusCode != 201 && response.statusCode != 200) {
                              showDialog(context: context, builder: (context) {
                                var errorType = jsonDecode(response.body).keys.toList()[0];
                                if (errorType.runtimeType != String) {
                                  errorType = errorType[0];
                                }
                                var errorDialog = jsonDecode(response.body).values.toList()[0];
                                if (errorDialog.runtimeType != String) {
                                  errorDialog = errorDialog[0];
                                }
                                return AlertDialog(
                                    title: Text(errorType),
                                    content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text(errorDialog),
                                          ],)));
                              });
                            }
                            _controller.nextPage(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.ease);
                            setState(() {
                              _selectedIdx++;
                            });
                          } catch(e) {
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(
                                  title: Text(e.toString()),
                                  content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(e.toString()),
                                        ],)));
                            });
                          }


                        },
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size(65, 65),
                          padding: const EdgeInsets.all(10),
                          side: BorderSide(width: 2.0, color: secondaryColor),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/right_arrow_gold.svg',
                          colorFilter:
                              ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }

  Scaffold _emailPage() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    var effectColor = Theme.of(context).canvasColor;
    return Scaffold(
      backgroundColor: primaryColor,
      body: ListView(children: [
        Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Newton(
                activeEffects: [
                  RainEffect(
                    particleConfiguration: ParticleConfiguration(
                      shape: CircleShape(),
                      size: const Size(5, 5),
                      color: SingleParticleColor(color: effectColor),
                    ),
                    effectConfiguration: const EffectConfiguration(),
                  )
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 7,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 25,
                    ),
                    Text(
                      'Register you account',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: secondaryColor,
                          fontSize: 20,
                          decorationColor: secondaryColor,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 30,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 25,
                    ),
                    Flexible(
                        child: Text(
                      'Welcome to Spo++fy',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.w300,
                          fontSize: 55,
                          fontStyle: FontStyle.italic),
                    )),
                    const SizedBox(
                      width: 25,
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      child: _typingField('Email', _goodEmail, _emailPrompt,
                          _emailController, 'assets/icons/email_gold.svg'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (!_goodEmail) return;
                        try {
                          var response = await http.post(
                              Uri.parse(
                                  'http://$fhlIP/api/auth/send_verification_code'),
                              headers: <String, String>{
                                'Content-Type': 'application/json; charset=UTF-8',
                              },
                              body: jsonEncode({'email': _emailController.text})
                          );
                          if (response.statusCode == 200 || response.statusCode == 201) {
                            setState(() {
                              _requestVerification = 0;
                            });
                            _emailTimer =
                                Timer.periodic(const Duration(seconds: 1), (timer) {
                                  setState(() {
                                    _buttonText = '$_countdownDuration s';
                                    _countdownDuration--;
                                    _buttonPressed = true;
                                  });
                                  if (_countdownDuration < 0) {
                                    setState(() {
                                      _countdownDuration = 60;
                                      _buttonText = 'Send code';
                                      timer.cancel();
                                    });
                                  }
                                });
                          }

                          showDialog(context: context, builder: (context) {
                            var errorType = jsonDecode(response.body).keys.toList()[0];
                            if (errorType.runtimeType != String) {
                              errorType = errorType[0];
                            }
                            var errorDialog = jsonDecode(response.body).values.toList()[0];
                            if (errorDialog.runtimeType != String) {
                              errorDialog = errorDialog[0];
                            }
                            return AlertDialog(
                                title: Text(errorType),
                                content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(errorDialog),
                                      ],)));
                          });
                        } catch(e) {
                          showDialog(context: context, builder: (context) {
                            return const AlertDialog(
                                title: Text('Internet Error'),
                                content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text('No Connection'),
                                      ],)));
                          });
                        }

                      },
                      style: TextButton.styleFrom(
                          backgroundColor: secondaryColor,
                          minimumSize: const Size(85, 50)),
                      child: Text(
                        _buttonText,
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 15),
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 30,
                ),
                Visibility(
                  visible: _buttonPressed,
                  child: _typingField(
                      'Verification Code',
                      _goodCode,
                      _emailVerificationPrompt,
                      _verificationController,
                      'assets/icons/verify_gold.svg'),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 10,
                ),
                Visibility(
                    visible: _goodEmail && _goodCode,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            try {
                              var response = await http.post(
                                  Uri.parse(
                                      'http://$fhlIP/api/auth/verify_email'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json; charset=UTF-8',
                                  },
                                  body: jsonEncode({'email': _emailController.text,
                                    'code' : _verificationController.text,
                                  })
                              );
                              if (response.statusCode != 200) {
                                showDialog(context: context, builder: (context) {
                                  var errorType = jsonDecode(response.body).keys.toList()[0];
                                  if (errorType.runtimeType != String) {
                                    errorType = errorType[0];
                                  }
                                  var errorDialog = jsonDecode(response.body).values.toList()[0];
                                  if (errorDialog.runtimeType != String) {
                                    errorDialog = errorDialog[0];
                                  }
                                  return AlertDialog(
                                      title: Text(errorType),
                                      content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text(errorDialog),
                                            ],)));
                                });
                              }
                              if (response.statusCode == 200 || response.statusCode == 201) {
                                _controller.nextPage(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.ease);
                              }
                            } catch(e) {
                              showDialog(context: context, builder: (context) {
                                return const AlertDialog(
                                    title: Text('error'),
                                    content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text('No Connection'),
                                          ],)));
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size(65, 65),
                            padding: const EdgeInsets.all(10),
                            side: BorderSide(width: 2.0, color: secondaryColor),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/right_arrow_gold.svg',
                            colorFilter: ColorFilter.mode(
                                secondaryColor, BlendMode.srcIn),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ]),
    );
  }


  Scaffold _personalInfoPage() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    var effectColor = Theme.of(context).canvasColor;
    return Scaffold(
      backgroundColor: primaryColor,
      body: ListView(children: [
        Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Newton(
                activeEffects: [
                  RainEffect(
                    particleConfiguration: ParticleConfiguration(
                      shape: CircleShape(),
                      size: const Size(5, 5),
                      color: SingleParticleColor(color: effectColor),
                    ),
                    effectConfiguration: const EffectConfiguration(),
                  )
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 7,
                ),
                _navigationBar,
                SizedBox(
                  height: MediaQuery.of(context).size.height / 20,
                ),
                _multilineField('Bio', _goodBio, _bioPrompt, _bioController,
                    'assets/icons/people_gold.svg'),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _controller.previousPage(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.ease);
                        setState(() {
                          _selectedIdx--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        fixedSize: const Size(65, 65),
                        padding: const EdgeInsets.all(10),

                        side: BorderSide(width: 2.0, color: secondaryColor),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/left_arrow_gold.svg',
                        colorFilter:
                            ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                      ),
                    ),
                    Visibility(
                      visible: _goodBio,
                      child: OutlinedButton(
                        onPressed: () async {
                          try {
                            var response = await http.patch(
                                Uri.parse('http://$fhlIP/api/profiles/update_by_email/${_emailController.text}/'),
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                },
                                body: jsonEncode({
                                  'bio' : _bioController.text,
                                })
                            );
                            if (response.statusCode != 201 || response.statusCode != 200) {
                              showDialog(context: context, builder: (context) {
                                var errorType = jsonDecode(response.body).keys.toList()[0];
                                if (errorType.runtimeType != String) {
                                  errorType = errorType[0];
                                }
                                var errorDialog = jsonDecode(response.body).values.toList()[0];
                                if (errorDialog.runtimeType == List) {
                                  errorDialog = errorDialog[0];
                                }
                                return AlertDialog(
                                    title: Text(errorType),
                                    content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text(errorDialog),
                                          ],)));
                              });
                            }
                            _controller.nextPage(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.ease);
                            setState(() {
                              _selectedIdx--;
                            });
                          } catch(e) {
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(
                                  title: Text(e.toString()),
                                  content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(e.toString()),
                                        ],)));
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size(65, 65),
                          padding: const EdgeInsets.all(10),
                          side: BorderSide(width: 2.0, color: secondaryColor),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/right_arrow_gold.svg',
                          colorFilter:
                              ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }

  Scaffold _finalPage() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    var effectColor = Theme.of(context).canvasColor;
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Newton(
            activeEffects: [
              RainEffect(
                particleConfiguration: ParticleConfiguration(
                  shape: CircleShape(),
                  size: const Size(5, 5),
                  color: SingleParticleColor(color: effectColor),
                ),
                effectConfiguration: const EffectConfiguration(),
              )
            ],
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox.expand(
                child: CustomPaint(
                  painter: WavePainter(
                      _animation.value, MediaQuery.of(context).size, context),
                ),
              );
            },
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.width / 3,
              child: IconButton(
                iconSize: _animation.value / 10,
                onPressed: () {
                  setState(() {
                    iconPlay = blackPlay;
                  });
                  _animationController.forward();
                },
                splashColor: primaryColor,
                icon: SvgPicture.asset(
                  iconPlay,
                  width: MediaQuery.of(context).size.width / 5,
                  height: MediaQuery.of(context).size.width / 5,
                  colorFilter: iconPlay == blackPlay
                      ? null
                      : ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late double _width;
  late double _height;

  bool _goodEmailFormat = false;
  bool _goodPasswordFormat = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkEmailFormat);
    _passwordController.addListener(_checkPasswordFormat);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _width = size.width;
      _height = size.height;
    });
  }

  void _checkEmailFormat() {
    String query = _emailController.text;
    setState(() {
      _goodEmailFormat = RegExp(emailPattern).hasMatch(query);
    });
  }

  void _checkPasswordFormat() {
    String query = _passwordController.text;
    setState(() {
      _goodPasswordFormat = RegExp(passwordPattern).hasMatch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    var effectColor = Theme.of(context).canvasColor;
    return Scaffold(
      backgroundColor: primaryColor,
      body: ListView(
        children: [
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Newton(
                  activeEffects: [
                    RainEffect(
                      particleConfiguration: ParticleConfiguration(
                        shape: CircleShape(),
                        size: const Size(5, 5),
                        color: SingleParticleColor(color: effectColor),
                      ),
                      effectConfiguration: const EffectConfiguration(),
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 25,
                      ),
                      Text(
                        'Login',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: secondaryColor,
                            fontSize: 20,
                            decorationColor: secondaryColor,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 30,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 25,
                      ),
                      Flexible(
                          child: Text(
                            'Welcome Back!',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: secondaryColor,
                                fontWeight: FontWeight.w300,
                                fontSize: 55,
                                fontStyle: FontStyle.italic),
                          )),
                      const SizedBox(
                        width: 25,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 30,
                  ),
                  _emailTypingField(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                  _passWordTypingField(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 7,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          if (_isLoading) return;
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            var response = await ApiService().login(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            // TODO: after logging in first time, the username is still unregistered. Fix this
                            if (response.statusCode == 200 || response.statusCode == 201) {
                              SharedPreferences.getInstance().then((sp) {
                                sp.setString('token', jsonDecode(response.body)['key']);
                              });
                              Navigator.pop(context);
                            } else {
                              _showError(response);
                            }
                          } catch(e) {
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(
                                  title: Text(e.toString()),
                                  content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(e.toString()),
                                        ],)));
                            });
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          fixedSize: const Size(65, 65),
                          padding: const EdgeInsets.all(10),
                          side: BorderSide(
                              width: 2.0, color: secondaryColor),
                        ),
                        child: SvgPicture.asset(
                            'assets/icons/right_arrow_gold.svg'),
                      ),
                    ],
                  ),
                  SizedBox(height: 40,),
                  Center(
                    child: TextButton(
                      child: Text(
                        'Do not have an account yet? Click me to register one now!',
                        style: TextStyle(fontSize: 17, color: secondaryColor,
                            fontStyle: FontStyle.italic, decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600, decorationColor: secondaryColor
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignupPage()));
                      },
                    ),
                  )
                ],
              ),
              if (_isLoading)
                Center(child: CircularProgressIndicator(color: secondaryColor,)),
            ],
          )
        ],
      ),
    );
  }
  void _showError(var response) {
    var errorType = jsonDecode(response.body).keys.toList()[0];
    if (errorType.runtimeType != String) {
      errorType = errorType[0];
    }
    var errorDialog = jsonDecode(response.body).values.toList()[0];
    if (errorDialog.runtimeType != String) {
      errorDialog = errorDialog[0];
    }
    showDialog(context: context, builder: (context) {
      return AlertDialog(
          title: Text(errorType),
          content: SingleChildScrollView(
              child: ListBody(
                  children: <Widget>[
                    Text(errorDialog),
                  ])));
    });
  }
  Column _emailTypingField() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    var effectColor = Theme.of(context).canvasColor;
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text('Email',
                style: TextStyle(
                  color: secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
          ),
        ]),
        Container(
            height: 50,
            margin: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
            ),
            child: TextField(
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: _emailController,
              style: TextStyle(
                  color: secondaryColor, decorationThickness: 0),
              decoration: InputDecoration(
                filled: false,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                contentPadding: const EdgeInsets.all(15),
                labelText: 'Enter Your Email',
                labelStyle: TextStyle(color: secondaryColor, fontSize: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    'assets/icons/user_gold.svg',
                    colorFilter:
                        ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Column _passWordTypingField() {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    var effectColor = Theme.of(context).canvasColor;
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text('Password',
                style: TextStyle(
                  color: secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                )),
          ),
        ]),
        Container(
            height: 50,
            margin: const EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
            ),
            child: TextField(
              onTapOutside: (PointerDownEvent event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              controller: _passwordController,
              style: TextStyle(
                  color: secondaryColor, decorationThickness: 0),
              decoration: InputDecoration(
                filled: false,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: secondaryColor, width: 2)),
                contentPadding: const EdgeInsets.all(15),
                labelText: 'Enter your Password',
                labelStyle: TextStyle(color: secondaryColor, fontSize: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    'assets/icons/user_gold.svg',
                    colorFilter:
                        ColorFilter.mode(secondaryColor, BlendMode.srcIn),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final double radius;
  final Size size;
  final BuildContext context;

  WavePainter(this.radius, this.size, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    var primaryColor = Theme.of(context).primaryColor;
    var secondaryColor = Theme.of(context).hintColor;
    var effectColor = Theme.of(context).canvasColor;
    final paint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height / 2),
        radius,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }


}
