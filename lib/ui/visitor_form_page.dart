import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import 'package:visitor_management_app/logic/visitor/visitor_state.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';

import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';
import '../models/visitor.dart';

class VisitorFormPage extends StatefulWidget {
  const VisitorFormPage({super.key, this.visitor});

  final Visitor? visitor;

  @override
  State<VisitorFormPage> createState() => _VisitorFormPageState();
}

class _VisitorFormPageState extends State<VisitorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _purpose = TextEditingController();

  String _type = 'Customer';
  String _project = 'Project A';
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final visitor = widget.visitor;
    if (visitor != null) {
      _name.text = visitor.name;
      _mobile.text = visitor.mobile;
      _email.text = visitor.email ?? '';
      _purpose.text = visitor.purpose;
      _type = visitor.visitorType;
      _project = visitor.project;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _email.dispose();
    _purpose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitorBloc, VisitorState>(
      listenWhen: (previous, current) =>
          previous.notice != current.notice ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (!_submitted) return;

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppTheme.red,
            ),
          );
          setState(() => _submitted = false);
          return;
        }

        if (state.notice != null) {
          final savedVisitor = state.selectedVisitor;
          if (savedVisitor == null || savedVisitor.id.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'The visitor was saved, but the API did not return a valid ID.',
                ),
              ),
            );
            setState(() => _submitted = false);
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.notice!),
              backgroundColor: AppTheme.green,
            ),
          );
          _submitted = false;

          // Replace the form route with details and pass the API-returned ID.
          // The details page uses this ID to render the visitor's QR code.
          context.go('/visitors/details', extra: savedVisitor);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.visitor == null ? 'Register visitor' : 'Edit visitor'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF292720),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.badge_outlined,
                        color: AppTheme.primary, size: 30),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visitor information',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fields marked required must be completed.',
                            style: TextStyle(
                              color: Color(0xFFD7D2C5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 23),
              _label('Visitor name *'),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter visitor name'
                    : null,
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              _label('Mobile number *'),
              TextFormField(
                controller: _mobile,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  hintText: '10-digit mobile number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  counterText: '',
                ),
                validator: (value) =>
                    value == null || !RegExp(r'^\d{10}$').hasMatch(value.trim())
                        ? 'Enter exactly 10 digits'
                        : null,
              ),
              const SizedBox(height: 16),
              _label('Email (optional)'),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isNotEmpty &&
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _label('Visitor type *'),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: const ['Customer', 'Vendor', 'Other']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _type = value ?? 'Customer'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),
              _label('Project *'),
              DropdownButtonFormField<String>(
                initialValue: _project,
                items: const ['Project A', 'Project B', 'Project C']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _project = value ?? 'Project A'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
              ),
              const SizedBox(height: 16),
              _label('Purpose of visit *'),
              TextFormField(
                controller: _purpose,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter purpose of visit'
                    : null,
                decoration: const InputDecoration(
                  hintText: 'e.g. Site visit, meeting with sales team',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 26),
              BlocBuilder<VisitorBloc, VisitorState>(
                builder: (context, state) {
                  final isSaving = state.status == VisitorStatus.saving;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSaving || _submitted
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isSaving || _submitted ? null : _save,
                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(
                            widget.visitor == null
                                ? 'Register'
                                : 'Save changes',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      );

  void _save() {
    if (_submitted || !_formKey.currentState!.validate()) return;

    final existing = widget.visitor;
    final visitor = Visitor(
      id: existing?.id ?? '',
      name: _name.text.trim(),
      mobile: _mobile.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      visitorType: _type,
      project: _project,
      purpose: _purpose.text.trim(),
      status: existing?.status ?? 'Registered',
      createdAt: existing?.createdAt ?? DateTime.now().toIso8601String(),
      checkInTime: existing?.checkInTime,
      checkOutTime: existing?.checkOutTime,
    );

    setState(() => _submitted = true);
    context.read<VisitorBloc>().add(VisitorSaved(visitor));
  }
}
