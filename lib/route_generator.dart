import 'package:flutter/material.dart';
import 'package:poolinspection/src/pages/booking/test.dart';
import 'package:poolinspection/src/pages/home/AddBankDetails.dart';
import 'package:poolinspection/src/pages/home/AddCardDetails.dart';
import 'package:poolinspection/src/pages/home/GetCertificateList.dart';
import 'package:poolinspection/src/pages/home/GetInvoiceList.dart';
import 'package:poolinspection/src/pages/home/InpsectorInvoiceList.dart';
import 'package:poolinspection/src/pages/home/ManageBookings.dart';
import 'package:poolinspection/src/pages/home/SelectNoticeOrNonCompliant.dart';
import 'package:poolinspection/src/pages/utils/signaturepad.dart';
import 'src/models/route_argument.dart';
import 'src/pages/booking/bookingform.dart';
import 'src/pages/home/home.dart';
import 'src/pages/login/login.dart';
import 'src/pages/reports/report.dart';
import 'src/pages/signup/signup.dart';
import 'src/pages/splashscreen/splash_screen.dart';
import 'src/pages/utils/addinspector.dart';
import 'src/pages/utils/forgetpassword.dart';
import 'src/pages/utils/updatepassword.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/Splash':
       // return MaterialPageRoute(builder: (_) => SplashScreen());
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/SignUp':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/UpdatePassword':
        return MaterialPageRoute(builder: (_) => UpdatePasswordWidget());
      case '/Home':
        return MaterialPageRoute(
            builder: (_) =>
                HomeWidget(routeArgument: args as RouteArgumentHome));

      case '/AddCardDetail':
        return MaterialPageRoute(builder: (_) => AddCardDetailWidget());
      case '/BankDetails':
        return MaterialPageRoute(builder: (_) => AddBankDetailWidget());
      case '/GetInvoiceList':
        return MaterialPageRoute(builder: (_) => InvoiceListClass());

      case '/Login':
        return MaterialPageRoute(builder: (_) => LoginWidget());
      case '/AddInspector':
        return MaterialPageRoute(builder: (_) => AddInspectorWidget());
      // case '/FullScreenImage':
      //   return MaterialPageRoute(
      //       builder: (_) =>
      //           FullScreenImage(routeArgument: args as ListDetailArgument));

      case '/ManageBookings':

        return MaterialPageRoute(
            builder: (_) =>
                ManageBookingWidget());


      case '/InspectorInvoice':
        return MaterialPageRoute(builder: (_) => InspectorInvoiceListClass());
      case '/NoticeReport':
        return MaterialPageRoute(
            builder: (_) =>
                NoticeReportWidget(routeArgument: args as RouteArgumentReport));

      case '/Certificate':
        return MaterialPageRoute(
            builder: (_) =>
                CertificateListClass(routeArgument: args as RouteArgumentCertificate));

      case '/ForgetPassword':
        return MaterialPageRoute(builder: (_) => ForgetPassword());
      // case '/ReportDetail':
      //   return MaterialPageRoute(builder: (_) => ReportDetailWidget(routeArgument: args as CompliantReportList));
//       case '/Tracking':
//         return MaterialPageRoute(builder: (_) => TrackingWidget(routeArgument: args as RouteArgument));
      // case '/Prefil':
      //   return MaterialPageRoute(builder: (_) => PreliminaryWidget(routeArgument: args as RouteArgument));
      case '/BookingForm':
        return MaterialPageRoute(builder: (_) => BookingFormWidget());
//       case '/CashOnDelivery':
//         return MaterialPageRoute(
//             builder: (_) => OrderSuccessWidget(routeArgument: RouteArgument(param: 'Cash on Delivery')));
//       case '/PayOnPickup':
//         return MaterialPageRoute(
//             builder: (_) => OrderSuccessWidget(routeArgument: RouteArgument(param: 'Pay on Pickup')));
//       case '/PayPal':
//         return MaterialPageRoute(builder: (_) => PayPalPaymentWidget(routeArgument: args as RouteArgument));
//       case '/OrderSuccess':
//         return MaterialPageRoute(builder: (_) => OrderSuccessWidget(routeArgument: args as RouteArgument));
//       case '/Languages':
//         return MaterialPageRoute(builder: (_) => LanguagesWidget());
//       case '/Help':
//         return MaterialPageRoute(builder: (_) => HelpWidget());
//       case '/Settings':
//         return MaterialPageRoute(builder: (_) => SettingsWidget());
//       default:
//         // If there is no such named route in the switch statement, e.g. /third
//         return MaterialPageRoute(builder: (_) => PagesTestWidget(currentTab: 2));
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
