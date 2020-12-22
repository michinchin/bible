import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../../blocs/content_settings.dart';
import '../../../models/app_settings.dart';
import '../../common/common.dart';
import 'study_res_bloc.dart';

class StudyResView extends StatelessWidget {
  final Size viewSize;
  final EdgeInsets padding;

  const StudyResView({Key key, this.viewSize, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyResBloc, StudyRes>(
      builder: (context, res) {
        return tec.isNullOrEmpty(res.html)
            ? const Center(child: LoadingIndicator())
            : SingleChildScrollView(
                child: BlocBuilder<ContentSettingsBloc, ContentSettings>(
                  builder: (context, settings) {
                    final marginWidth = (viewSize.width * _marginPercent).roundToDouble();
                    var _padding = (padding ?? EdgeInsets.zero);
                    _padding = padding.copyWith(
                      left: padding.left + marginWidth,
                      right: padding.right + marginWidth,
                    );

                    return TecHtml(
                      res.html,
                      baseUrl: VolumesRepository.shared.volumeWithId(res.volumeId)?.baseUrl,
                      backgroundColor: Theme.of(context).backgroundColor,
                      textScaleFactor: contentTextScaleFactorWith(context),
                      padding: _padding,
                    );
                  },
                ),
              );
      },
    );
  }
}

const _marginPercent = 0.05; // 0.05;
