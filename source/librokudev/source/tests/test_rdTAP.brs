' *********************************************************************
' * libRokuDev, Test Library for rdTAP.brs                            *
' *                                                                   *
' * Copyright 2010, GandK Labs.  This library is free software; see   *
' * the LICENSE file in the libRokuDev distribution for more details. *
' *********************************************************************

' ****************************************************************************
' * Main entry point for testing rdTAP; currently all output goes to console *
' ****************************************************************************
Sub test_rdTAP()
    harness = rdTAPHarness({ verbose: 1, extra_test_args: {} })
    harness.run_tests([ test_rdTAP_passes, test_rdTAP_fails ])

    harness.set_options({ extra_test_args: { harness: harness } })
    harness.run_tests([ test_rdTAP_harness ])

    harness.show_summary()
End Sub

' ************************************************************************
' * Test correct usage and passing cases; all of these tests should pass *
' ************************************************************************
Sub test_rdTAP_passes(t, args)
    t.ok(true) 'Basic boolean ok() without a message
    t.ok(true, "Basic boolean ok() with message")
    t.ok(5,    "ok() with integer used as boolean")
    t.ok(3.14, "ok() with float   used as boolean")
    t.ok(1.1#, "ok() with double  used as boolean")

    t.pass()   'pass() without a message
    t.pass(    "pass() with a message")

    t.is(true,  true)  'is() with matching true  booleans without a message
    t.is(true,  true,  "is() with matching true  booleans")
    t.is(false, false, "is() with matching false booleans")
    t.is(42,    42,    "is() with matching true  integers")
    t.is(0,     0,     "is() with matching false integers")
    t.is(2.72,  2.72,  "is() with matching true  floats")
    t.is(0.0,   0.0,   "is() with matching false floats")
    t.is(1.7#,  1.7#,  "is() with matching true  doubles")
    t.is(0.0#,  0.0#,  "is() with matching false doubles")
    t.is(invalid, invalid, "is() with matching invalids")

    t.isnt(true,  false) 'isnt() with mismatched booleans (true on left) without a message
    t.isnt(true,  false, "isnt() with mismatched booleans (true on left)")
    t.isnt(false, true,  "isnt() with mismatched booleans (true on right)")
    t.isnt(7,     0,     "isnt() with mismatched integers (true on left)")
    t.isnt(0,     12,    "isnt() with mismatched integers (true on right)")
    t.isnt(16,    32,    "isnt() with mismatched integers (both true)")
    t.isnt(0.12,  0.0,   "isnt() with mismatched floats   (true on left)")
    t.isnt(0.0,   2.3,   "isnt() with mismatched floats   (true on right)")
    t.isnt(4.56,  7.89,  "isnt() with mismatched floats   (both true)")
    t.isnt(9.87#, 0.0#,  "isnt() with mismatched doubles  (true on left)")
    t.isnt(0.0#,  6.5#,  "isnt() with mismatched doubles  (true on right)")
    t.isnt(4.32#, 2.10#, "isnt() with mismatched doubles  (both true)")

    t.like("aaa", "^a+$")    'like() without a message
    t.like("aba", "^[ab]+$", "like() with a message")

    t.unlike("aaa", "^b+$")  'unlike() without a message
    t.unlike("aba", "^w+$",  "unlike() with a message")

    t.can_ok(t, "plan") 'can_ok() without a message
    t.can_ok(t, "isnt", "can_ok() with a message")

    t.has_ok(t, "_num_tests") 'has_ok() without a message
    t.has_ok(t, "_cur_test",  "has_ok() with a message")

    t.cmp_ok(invalid, "=",  invalid) 'cmp_ok(=)  with matching invalids without a message
    t.cmp_ok(invalid, "=",  invalid, "cmp_ok(=)  with matching invalids")
    t.cmp_ok(true,    "=",  true,    "cmp_ok(=)  with matching true booleans")
    t.cmp_ok(false,   "=",  false,   "cmp_ok(=)  with matching false booleans")
    t.cmp_ok(true,    "<>", false,   "cmp_ok(<>) with mismatched booleans (true on left)")
    t.cmp_ok(false,   "<>", true,    "cmp_ok(<>) with mismatched booleans (true on right)")
    t.cmp_ok(37,      "=",  37,      "cmp_ok(=)  with matching true integers")
    t.cmp_ok(0,       "=",  0,       "cmp_ok(=)  with matching false integers")
    t.cmp_ok(77,      "<>", 37,      "cmp_ok(<>) with mismatched true integers")
    t.cmp_ok(5,       "<",  7,       "cmp_ok(<)  with smaller integer on left")
    t.cmp_ok(8,       ">",  6,       "cmp_ok(>)  with smaller integer on right")
    ' This could go on for a very long time, but we won't ....

    t.done_testing()
End Sub

' **************************************************************************
' * Test incorrect usage and failing cases; all of these tests should fail *
' **************************************************************************
Sub test_rdTAP_fails(t, args)
    t.plan(2)

    t.ok(false) 'Failing boolean ok() without a message
    t.ok(false, "Failing boolean ok() with message")
    t.ok(0,     "Failing ok() with integer used as boolean")
    t.ok(0.0,   "Failing ok() with float   used as boolean")
    t.ok(0.0#,  "Failing ok() with double  used as boolean")

    t.fail()   'fail() without a message
    t.fail(    "fail() with a message")

    t.is(true,  false) 'is() with mismatched booleans (true on left) without a message
    t.is(true,  false, "is() with mismatched booleans (true on left)")
    t.is(false, true,  "is() with mismatched booleans (true on right)")
    t.is(7,     0,     "is() with mismatched integers (true on left)")
    t.is(0,     12,    "is() with mismatched integers (true on right)")
    t.is(16,    32,    "is() with mismatched integers (both true)")
    t.is(0.12,  0.0,   "is() with mismatched floats   (true on left)")
    t.is(0.0,   2.3,   "is() with mismatched floats   (true on right)")
    t.is(4.56,  7.89,  "is() with mismatched floats   (both true)")
    t.is(9.87#, 0.0#,  "is() with mismatched doubles  (true on left)")
    t.is(0.0#,  6.5#,  "is() with mismatched doubles  (true on right)")
    t.is(4.32#, 2.10#, "is() with mismatched doubles  (both true)")

    t.isnt(true,  true)  'isnt() with matching true  booleans without a message
    t.isnt(true,  true,  "isnt() with matching true  booleans")
    t.isnt(false, false, "isnt() with matching false booleans")
    t.isnt(42,    42,    "isnt() with matching true  integers")
    t.isnt(0,     0,     "isnt() with matching false integers")
    t.isnt(2.72,  2.72,  "isnt() with matching true  floats")
    t.isnt(0.0,   0.0,   "isnt() with matching false floats")
    t.isnt(1.7#,  1.7#,  "isnt() with matching true  doubles")
    t.isnt(0.0#,  0.0#,  "isnt() with matching false doubles")
    t.isnt(invalid, invalid, "isnt() with matching invalids")

    t.like("zzz", "^q+$")    'Failing like() without a message
    t.like("ozo", "^[cd]+$", "Failing like() with a message")

    t.unlike("yyy", "^y+$")    'Failing unlike() without a message
    t.unlike("bxb", "^[bx]+$", "Failing unlike() with a message")

    t.can_ok(t, "flurb")   'Failing can_ok() without a message
    t.can_ok(t, "blarfle", "Failing can_ok() with a message")

    t.has_ok(t, "sqizzl")  'Failing has_ok() without a message
    t.has_ok(t, "flilax",  "Failing has_ok() with a message")

    t.cmp_ok(invalid, "<>", invalid) 'cmp_ok(<>) with matching invalids without a message
    t.cmp_ok(invalid, "<>", invalid, "cmp_ok(<>) with matching invalids")
    t.cmp_ok(true,    "<>", true,    "cmp_ok(<>) with matching true booleans")
    t.cmp_ok(false,   "<>", false,   "cmp_ok(<>) with matching false booleans")
    t.cmp_ok(true,    "=",  false,   "cmp_ok(=)  with mismatched booleans (true on left)")
    t.cmp_ok(false,   "=",  true,    "cmp_ok(=)  with mismatched booleans (true on right)")
    t.cmp_ok(37,      "<>", 37,      "cmp_ok(<>) with matching true integers")
    t.cmp_ok(0,       "<>", 0,       "cmp_ok(<>) with matching false integers")
    t.cmp_ok(77,      "=",  37,      "cmp_ok(=)  with mismatched true integers")
    t.cmp_ok(5,       ">",  7,       "cmp_ok(>)  with smaller integer on left")
    t.cmp_ok(8,       "<",  6,       "cmp_ok(<)  with smaller integer on right")
    ' This could go on for a very long time, but we won't ....

    t.done_testing(3)
End Sub

' *********************************************************************
' * Test that the rdTAP harness correctly interprets the other tests; *
' * all of these tests should pass                                    *
' *********************************************************************
Sub test_rdTAP_harness(t, args)
    harness = args.harness
    t.isa_ok(harness, "roAssociativeArray", "harness is a user-defined object")

    t.has_ok(harness, "_raw_results",       "harness has a _raw_results private attribute")
    t.has_ok(harness, "_summaries",         "harness has a _summaries private attribute")
    t.is(harness._raw_results.count(), 2,   "_raw_results has two entries")
    t.is(harness._summaries.count(),   2,   "_summaries has two entries")

    good = harness._summaries[0]
    t.cmp_ok(good.planned, ">", 0, "Good set planned > 0 tests")
    t.is(good.planned, good.ran,   "Good set ran all planned tests")
    t.is(good.ran, good.passed,    "Good set passed all run tests")
    t.is(good.failed, 0,           "Good set didn't fail any tests")
    t.is(good.dubious, 0,          "Good set didn't have any dubious tests")

    bad = harness._summaries[1]
    t.cmp_ok(bad.planned, ">", 0,  "Bad set planned > 0 tests")
    t.isnt(bad.planned, bad.ran,   "Bad set didn't run planned tests")
    t.is(bad.passed, 0,            "Bad set didn't pass any tests")
    t.is(bad.failed, bad.ran,      "Bad set failed all run tests")
    t.cmp_ok(bad.dubious, ">", 0,  "Bad set had dubious tests")

    t.done_testing()
End Sub
