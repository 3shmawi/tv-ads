import 'package:flutter/material.dart';
import 'package:tv_ads/model/ad.dart';
import 'package:tv_ads/view/admin/upload_media.dart';

class UploadEditAdView extends StatefulWidget {
  const UploadEditAdView({this.adModel, super.key});

  final AdModel? adModel;

  @override
  State<UploadEditAdView> createState() => _UploadEditAdViewState();
}

class _UploadEditAdViewState extends State<UploadEditAdView> {
  int pageIndex = 0;

  final _formKey = GlobalKey<FormState>();

  final _idCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  String? _aspectRatio;

  @override
  void initState() {
    super.initState();
    if (widget.adModel != null) {
      _idCtrl.text = widget.adModel!.id;
      _titleCtrl.text = widget.adModel!.title;
      _locationCtrl.text = widget.adModel!.location;
      _durationCtrl.text = widget.adModel!.duration.toString();
      _aspectRatio = widget.adModel!.scale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
            widget.adModel == null ? "إضافة إعلانات جديدة" : "تعديل الإعلان"),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: pageIndex,
          onStepCancel: pageIndex > 0
              ? () {
                  setState(() {
                    pageIndex--;
                  });
                }
              : null,
          onStepContinue: () {
            if (_formKey.currentState!.validate()) {
              if (pageIndex == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdUploadPage(
                      widget.adModel ??
                          AdModel(
                            id: _idCtrl.text,
                            ads: [],
                            title: _titleCtrl.text,
                            location: _locationCtrl.text,
                            scale: _aspectRatio!,
                            duration: int.parse(_durationCtrl.text),
                          ),
                    ),
                  ),
                );
              } else {
                setState(() {
                  pageIndex++;
                });
              }
            }
          },
          controlsBuilder: _controlButton,
          steps: [
            _page1(),
            _page2(),
            _page3(),
          ],
        ),
      ),
    );
  }

  Step _page3() {
    return Step(
      isActive: pageIndex == 2,
      content: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                "تم التجهيز، يمكنك الآن الانتقال للمرحلة التالية",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      title: Text("تحميل الإعلانات"),
    );
  }

  Step _page2() {
    return Step(
      isActive: pageIndex == 1,
      title: Text("معلومات عن شاشة العرض"),
      content: Column(
        children: [
          const SizedBox(height: 5),
          TextFormField(
            controller: _durationCtrl,
            keyboardType: TextInputType.number,
            validator: (value) {
              //validate if is just a number using regex
              if ((value!.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(value)) &&
                  pageIndex == 1) {
                return "يجب إدخال رقم صحيح";
              }

              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "مدة عرض الإعلان الواحد بالثانية",
              labelStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _titleCtrl,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value!.isEmpty && pageIndex == 1) {
                return "يجب إدخال اسم أو معلومات عن الشاشة";
              }

              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "اسم أو معلومات عن الشاشة",
              labelStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _locationCtrl,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value!.isEmpty && pageIndex == 1) {
                return "أدخل عنوان الشاشة";
              }

              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "عنوان شاشة العرض",
              labelStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _aspectRatio,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              labelText: 'مقاسات شاشة العرض',
            ),
            items: [
              "21:9",
              "18:9",
              "16:10",
              "16:9",
              "5:4",
              "4:3",
              "3:2",
              "1.85:1",
              "1:1",
              "2.39:1",
            ].map((String ratio) {
              return DropdownMenuItem<String>(
                value: ratio,
                child: Text(ratio),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _aspectRatio = newValue;
              });
            },
            validator: (value) {
              if ((value == null || value.isEmpty) && pageIndex == 1) {
                return 'اختر أبعاد الشاشة';
              }
              return null;
            },
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Step _page1() {
    return Step(
      isActive: pageIndex == 0,
      title: Text("ادخال الرقم التسلسلي للإعلان"),
      content: Column(
        children: [
          TextFormField(
            readOnly: widget.adModel != null,
            controller: _idCtrl,
            keyboardType: TextInputType.number,
            validator: (value) {
              //validate if is just a number using regex
              if ((value!.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(value)) &&
                  pageIndex == 0) {
                return "يجب إدخال رقم صحيح";
              }

              return null;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: "رقم التسلسلي للإعلان",
              labelStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              hintText: "12345",
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _controlButton(context, details) {
    return Row(
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 10,
          ),
          onPressed: details.onStepCancel,
          child: Text("عودة"),
        ),
        SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: details.onStepContinue,
            child: Text(pageIndex == 2 ? "تأكيد، ثم تحميل" : "التالي"),
          ),
        ),
      ],
    );
  }
}
