import 'package:absensi_apps/api/register_user.dart';
import 'package:absensi_apps/extension/navigation.dart';
import 'package:absensi_apps/models/get_batches_model.dart';
import 'package:absensi_apps/models/get_list_training_model.dart';
import 'package:absensi_apps/shared_preferences.dart/shared_preference.dart';
import 'package:absensi_apps/views/buttom_nav.dart';
import 'package:absensi_apps/views/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const id = "/register_screen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isVisibility = false;
  String? errorMessage;
  String? dropdownSelect;
  List<Datum>? trainingList = [];
  Datum? selectedTraining;
  List<Batch>? batchList = [];
  Batch? selectedBatches;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    try {
      final trainingResponse = await AuthenticationAPI.getListTraining();
      setState(() {
        trainingList = trainingResponse.data;
      });
    } catch (e) {
      print('Error loading trainings: $e');
    }
  }

  Future<void> _loadBatches() async {
    try {
      final bacthesResponse = await AuthenticationAPI.getListBatch();
      setState(() {
        batchList = bacthesResponse.data;
      });
    } catch (e) {
      print('Error loading trainings: $e');
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final registerResponse = await AuthenticationAPI.registerUser(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        PreferenceHandler.saveToken(registerResponse.data?.token ?? '');
        context.pushReplacement(ButtomNav());
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registrasi gagal: $e')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              "Daftar Akun",
              style: TextStyle(fontSize: 20, fontFamily: "StageGrotesk_Bold"),
            ),
            SizedBox(height: 20),
            Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: const Color.fromARGB(55, 0, 0, 0),
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                  image: AssetImage("assets/images/ikon kamera.png"),
                ),
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(height: 10),

                  Text(
                    "Nama Lengkap",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "StageGrotesk_Regular",
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextFormField(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10),
                        prefixIcon: Transform.translate(
                          offset: Offset(0, -1),
                          child: Icon(Icons.person),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Nama Lengkap Anda",
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "StageGrotesk_Regular",
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10),
                        prefixIcon: Transform.translate(
                          offset: Offset(0, -1),
                          child: Icon(Icons.email),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Email Anda",
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "StageGrotesk_Regular",
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: !isVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10),
                        prefixIcon: Transform.translate(
                          offset: Offset(0, -1),
                          child: Icon(Icons.lock),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "Password Anda",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisibility = !isVisibility;
                            });
                          },
                          icon: Icon(
                            isVisibility
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    "Training",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "StageGrotesk_Regular",
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    // height: 65,
                    child: DropdownButtonFormField<Datum>(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      value: selectedTraining,
                      hint: Text(
                        "Pilih Training",
                        style: TextStyle(fontFamily: "StageGrotesk_Regular"),
                      ),
                      items:
                          trainingList?.map((Datum training) {
                            return DropdownMenuItem<Datum>(
                              value: training,
                              child: Text(training.title ?? ''),
                            );
                          }).toList() ??
                          [],
                      onChanged: (value) {
                        setState(() {
                          selectedTraining = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    // height: 65,
                    child: DropdownButtonFormField<Batch>(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      value: selectedBatches,
                      hint: Text(
                        "Pilih Training",
                        style: TextStyle(fontFamily: "StageGrotesk_Regular"),
                      ),
                      items:
                          batchList?.map((Batch batch) {
                            return DropdownMenuItem<Batch>(
                              value: batch,
                              child: Text((batch.batchKe ?? '')),
                            );
                          }).toList() ??
                          [],
                      onChanged: (value) {
                        setState(() {
                          selectedBatches = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Daftar",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: "StageGrotesk_Bold",
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 100),
                    child: Text.rich(
                      TextSpan(
                        text: "Sudah punya akun? ",
                        style: TextStyle(
                          color: const Color.fromARGB(182, 100, 100, 106),
                          fontFamily: "StageGrotesk_Regular",
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push(LoginScreen());
                              },
                            text: " Masuk",
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color.fromARGB(255, 11, 39, 164),
                              fontFamily: "StageGrotesk_Bold",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
