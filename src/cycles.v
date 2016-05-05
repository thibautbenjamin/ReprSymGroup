Require Import mathcomp.ssreflect.ssreflect.
From mathcomp Require Import ssrfun ssrbool eqtype ssrnat seq choice fintype div.
From mathcomp Require Import tuple finfun path bigop finset binomial.
From mathcomp Require Import fingroup perm automorphism action ssralg.
From mathcomp Require finmodule.

From Combi Require Import symgroup partition Greene tools sorted.

Require Import bij.

Set Implicit Arguments.
Unset Strict Implicit.



Section Bla.

Variable T1 T2 : eqType.
Variable P : T1 -> T2 -> Prop.
Hypothesis H : forall x, {y | P x y}.


Definition F (x : T1) : T2 := let (y, _) := H x in y.

Lemma bla : forall x, P x (F x).
Proof.
  rewrite /F => x /=.
  by case: (H x) => y Py /=.
Qed.

End Bla.

Section SSRComplements.
Variable T: finType.

Variables (R : Type) (idx : R) (op : R -> R -> R) (F : T -> R).

Lemma big_enum (S : {set T}) :
  \big[op/idx]_(s in S) F s = \big[op/idx]_(s <- enum S) F s.
Proof. by rewrite /index_enum big_filter; apply congr_big. Qed.

Lemma triv_part (P:{set {set T}}) (X:{set T}) (D:{set T}):
  partition P D -> X \in P -> D \subset X -> P = [set X].
Proof.
  rewrite /partition => /and3P [] /eqP Hcov /trivIsetP /(_ X) H H0 HXP /subsetP HD.
  case: (set_0Vmem (P :\ X)) => [/eqP | [Y]].
  - rewrite setD_eq0 subset1 => /orP [] /eqP // Hcontra.
    by move: HXP; rewrite Hcontra inE.
  - rewrite in_setD1 => /andP [].
    rewrite eq_sym => Hdiff HYP.
    move/(_ Y HXP HYP Hdiff): H => /disjoint_setI0 HXY.
    case: (set_0Vmem Y) => [HY | [] x HxY]; first by move: H0; rewrite -HY => /negP.
    have: x \in cover P by apply /bigcupP; exists Y.
    rewrite Hcov => /(HD x) HxX.
    have: x \in X :&: Y by rewrite inE; apply /andP.
    by rewrite HXY inE.
Qed.

Lemma partition_of0 (P:{set {set T}}):
  partition P set0 -> P = set0.
Proof.
  rewrite /partition => /and3P [] /eqP H1 _ H2.
  case: (set_0Vmem P) => [// | [] X].
  case: (set_0Vmem X) => [-> H3 | [] x Hx HX]; first by move: H2 => /negP.
  have: x \in cover P by apply /bigcupP; exists X.
  by rewrite H1 inE.
Qed.

Lemma pcycleP (s: {perm T}) x y :
  reflect (exists i, y = (s ^+ i)%g x) (y \in pcycle s x).
Proof.
  apply (iffP idP).
  - rewrite pcycle_traject => H.
    have:= H; rewrite -index_mem size_traject => Hlt.
    exists (index y (traject s x #|pcycle s x|)).
    move: Hlt => /(nth_traject s)/(_ x); rewrite (nth_index _ H) => {H} {1}->.
    elim: (index _ _) => [|n IHn] /=; first by rewrite expg0 perm1.
    by rewrite expgSr permM IHn.
  - move=> [i ->]; exact: mem_pcycle.
Qed.

Lemma pcycle_perm1 (s: {perm T}) x : pcycle s (s x) = pcycle s x.
Proof. by rewrite -{2}(expg1 s); exact: pcycle_perm. Qed.

Lemma pcycle_setP (s: {perm T}) x y :
  (y \in pcycle s x) -> {i | y = (s ^+ i)%g x}.
Proof.
  rewrite pcycle_traject => H.
  have:= H; rewrite -index_mem size_traject => Hlt.
  exists (index y (traject s x #|pcycle s x|)).
  move: Hlt => /(nth_traject s)/(_ x); rewrite (nth_index _ H) => {H} {1}->.
  elim: (index _ _) => [|n IHn] /=; first by rewrite expg0 perm1.
  by rewrite expgSr permM IHn.
Qed.

Lemma enum_eq0P (s : {set T}):
  reflect (enum s = [::]) (s == set0).
Proof.
  apply (iffP eqP) => [-> |]; first exact: enum_set0.
  case: (set_0Vmem s) => [-> //| [x]].
  rewrite -mem_enum => Hx Hnil.
  by rewrite Hnil in_nil in Hx.
Qed.

End SSRComplements.


Section PermCycles.
Variable T: finType.
Implicit Type (s: {perm T}).

Definition support s := ~:'Fix_('P)([set s])%g.

Lemma in_support s x : (x \in support s) = (s x != x).
Proof.
  apply /idP/idP => [| /eqP H]; rewrite inE.
  - by move => /afix1P /= /eqP.
  - by apply /afix1P => /=; rewrite apermE.
Qed.

Lemma support_card_pcycle s x : (#|pcycle s x| != 1) = (x \in support s).
Proof.
  rewrite in_support; congr negb; apply/eqP/eqP.
  - by rewrite -{3}(iter_pcycle s x) => -> /=.
  - move=> Hx; apply/eqP/cards1P; exists x.
    rewrite -setP => y; rewrite !inE.
    apply/idP/eqP => [/pcycleP [i ->] | ->]; last exact: pcycle_id.
    elim: i => [| i IHi]; first by rewrite expg0 perm1.
    by rewrite expgSr permM IHi.
Qed.

Lemma pcycle_fix s x : (s x == x) = (pcycle s x == [set x]).
Proof.
  apply/eqP/eqP => [Hx | ].
  - rewrite -setP => y; rewrite inE.
    apply/idP/eqP => [| ->]; last exact: pcycle_id.
    move=> /pcycleP [i ->].
    elim: i => [| i IHi]; first by rewrite expg0 perm1.
    by rewrite expgSr permM IHi.
  - rewrite -setP => Hy.
    have:= mem_pcycle s 1 x.
    by rewrite expg1 Hy inE => /eqP.
Qed.

Lemma support_perm_on S s : (perm_on S s) = (support s \subset S).
Proof.
  apply/subsetP/subsetP => H x.
  - rewrite in_support; exact: H.
  - rewrite inE -in_support; exact: H.
Qed.

Lemma support_eq0 s : (s == perm_one T) = (support s == set0).
Proof.
  apply/eqP/eqP => [ -> |].
  - apply/setP => x; by rewrite in_support inE perm1 eq_refl.
  - move/setP => Heq; rewrite -permP => x.
    move/(_ x): Heq; by rewrite in_support inE perm1 => /eqP.
Qed.

Lemma support1 : support (perm_one T) = set0.
Proof. by apply /eqP; rewrite -support_eq0. Qed.

Lemma support_stable s x : (x \in support s) = (s x \in support s).
Proof.
  rewrite !in_support; congr negb; apply/idP/idP => [/eqP -> // | /eqP H].
  by rewrite -[s x](permK s) H permK.
Qed.

Lemma card_support_noteq1 s : #|support s| != 1.
Proof.
  apply /cards1P => [] [x] Hsupp.
  have: s x == x.
    by rewrite -in_set1 -Hsupp -support_stable Hsupp inE.
  by move => /eqP; apply /eqP; rewrite -in_support Hsupp inE.
Qed.

Definition psupport s := [set x in pcycles s | #|x| != 1].

Lemma in_psupportP s (X: {set T}) x:
  reflect (exists2 X, X \in psupport s & x \in X) (s x != x).
Proof.
  rewrite -in_support; apply (iffP idP) => [/setCP Hy | [Y]].
  - exists (pcycle s x); last by apply: pcycle_id.
    rewrite inE; apply /andP; split.
    + by apply /imsetP; exists x.
    + apply /negP; rewrite pcycleE => /eqP /card_orbit1 /orbit1P.
      by rewrite afix_cycle // inE.
  - rewrite inE => /andP [] /imsetP [y _ -> {Y}] Hcard Heq.
    move: Heq Hcard; rewrite in_support -eq_pcycle_mem => /eqP <- {y}.
    apply contra => /eqP.
    rewrite pcycleE -apermE => /afix1P.
    rewrite -afix_cycle => /orbit1P ->.
    by rewrite cards1.
Qed.

Lemma partition_pcycles s : partition (pcycles s) setT.
Proof.
  apply /and3P; split.
  - rewrite /cover; apply/eqP/setP => y.
    rewrite inE; apply/bigcupP; exists (pcycle s y).
    + exact: mem_imset.
    + exact: pcycle_id.
  - apply /trivIsetP => A B /imsetP [] x1 _ -> /imsetP [] x2 _ -> Hdiff.
    rewrite -setI_eq0; apply /set0Pn => [] [y].
    rewrite inE => /andP [].
    by rewrite -!eq_pcycle_mem => /eqP ->; apply /negP.
  - apply /negP => /imsetP [] x _ Heq.
    by have:= pcycle_id s x; rewrite -Heq inE.
Qed.

Lemma partition_support s : partition (psupport s) (support s).
Proof.
  apply /and3P; split.
  - rewrite /cover; apply/eqP/setP => y.
    rewrite (_ : (y \in \bigcup_(B in psupport s) B) = (s y != y)).
    + by rewrite in_support.
    + by apply /bigcupP/in_psupportP => //; exact: support s.
  - apply /trivIsetP => A B.
    rewrite !inE => /andP [] /imsetP [] x1 _ -> _
                    /andP [] /imsetP [] x2 _ -> _ Hdiff.
    rewrite -setI_eq0; apply /set0Pn => [] [y].
    rewrite inE => /andP [].
    by rewrite -!eq_pcycle_mem => /eqP ->; apply /negP.
  - apply /negP; rewrite inE => /andP [] H _.
    move: H => /imsetP [] x _ Heq.
    by have:= pcycle_id s x; rewrite -Heq inE.
Qed.

Lemma psupport_astabs s X:
   X \in psupport s -> s \in ('N(X | 'P))%g.
Proof.
  rewrite /astabs => HX.
  rewrite inE; apply /andP; split; rewrite inE //.
  apply /subsetP => x /= Hx.
  move: HX; rewrite !inE apermE => /andP [] /imsetP [] x0 _ HX _.
  move: Hx; rewrite HX -!eq_pcycle_mem => /eqP <-.
  by rewrite pcycle_perm1.
Qed.


Definition is_cycle s := #|psupport s| == 1.
Definition cycle_dec s : {set {perm T}} := [set restr_perm X s | X in psupport s].

Lemma out_restr s (X: {set T}) x : x \notin X -> restr_perm X s x = x.
Proof. apply: out_perm; exact: restr_perm_on. Qed.

Lemma support_restr_perm s X:
  X \in psupport s -> support (restr_perm X s) = X.
Proof.
  move => HX.
  apply /setP => y; apply /idP/idP => [|Hin].
  - rewrite in_support.
    by apply contraR => /out_restr /eqP.
  - rewrite in_support restr_permE ?psupport_astabs // -?in_support.
    rewrite -(cover_partition (partition_support s)).
    by apply /bigcupP; exists X.
Qed.

Lemma pcycle_restr_perm s x y :
  y \in pcycle s x ->
  pcycle (restr_perm (pcycle s x) s) y = pcycle s y.
Proof.
  case: (boolP (pcycle s x \in psupport s)) => [Hx Hy |].
  - have Hiter (i:nat): ((restr_perm (pcycle s x) s)^+i)%g y = (s^+i)%g y.
      elim: i => [|n Hn]; first by rewrite !expg0 !perm1.
      rewrite !expgSr !permM {}Hn restr_permE //; first exact: psupport_astabs.
      by rewrite -eq_pcycle_mem pcycle_perm eq_pcycle_mem.
    apply /setP => z; apply /pcycleP/pcycleP => [] [n].
    + by rewrite Hiter => ->; exists n.
    + by rewrite -Hiter => ->; exists n.
  - (* This case is overly complicated and actually not needed *)
    rewrite inE mem_imset //= support_card_pcycle.
    rewrite in_support negbK pcycle_fix => /eqP H.
    rewrite H inE => /eqP -> {y}.
    rewrite H -setP => y; rewrite inE.
    apply/pcycleP/eqP => [[n]|] ->{y}; last by exists 0; rewrite expg0 perm1.
    move: H => /eqP; rewrite -pcycle_fix => /eqP Hx.
    elim: n => [| n IHn]; first by rewrite expg0 perm1.
    rewrite expgSr permM {}IHn restr_permE // !inE //=.
    apply /subsetP => y /=; rewrite !inE => /eqP ->.
    by rewrite apermE Hx.
Qed.

Lemma psupport_restr s X:
  X \in psupport s -> psupport (restr_perm X s) = [set X].
Proof.
  move => H; have:= H; rewrite inE => /andP [/imsetP [x _ Hx] HX]; subst X.
  apply /setP => Y; rewrite [RHS]inE.
  apply /idP/idP => [HY | /eqP -> {Y}].
  - have HYX : Y \subset (pcycle s x).
      rewrite -(support_restr_perm H).
      rewrite -(cover_partition (partition_support _)).
      by apply (bigcup_max _ HY).
    rewrite eqEsubset; apply /andP; split => //.
    move: HYX => /subsetP HYX.
    move: HY; rewrite inE => /andP [/imsetP[y _ Hy] _].
    have {Hy} Hy : Y = pcycle s y.
      rewrite Hy; apply pcycle_restr_perm; apply HYX; rewrite Hy; exact: pcycle_id.
    subst Y; apply/subsetP => z.
    have:= pcycle_id s y => /HYX.
    by rewrite -eq_pcycle_mem => /eqP <-.
 -  rewrite inE HX andbT.
    apply /imsetP; exists x => //.
    apply esym; apply pcycle_restr_perm; exact: pcycle_id.
Qed.

Lemma psupport_eq0 s : (s == perm_one T) = (psupport s == set0).
Proof.
  rewrite support_eq0; apply/eqP/eqP => Hsup.
  - have:= partition_support s; rewrite {}Hsup.
    by move => /partition_of0 ->.
  - have:= partition_support s; rewrite {}Hsup.
    rewrite /partition => /and3P [] /eqP <- _ _.
    by rewrite /cover big_set0.
Qed.

Lemma is_cycle_dec s : {in (cycle_dec s), forall C, is_cycle C}.
Proof.
  move => C /imsetP [X HX ->].
  by rewrite /is_cycle psupport_restr ?cards1.
Qed.

Definition support_cycles (s : {perm T}) :=
  [set support C | C in cycle_dec s].

Lemma support_cycle_dec s :
  support_cycles s = psupport s.
Proof.
  apply /setP => X; apply /imsetP/idP.
  - move => [x /imsetP[x0 Hx0 ->] ->].
    by rewrite support_restr_perm.
  - rewrite inE => /andP [HX1 HX2].
    have HX: X \in psupport s by rewrite inE HX1 HX2.
    exists (restr_perm X s); last by rewrite support_restr_perm.
    by apply /imsetP; exists X.
Qed.

Definition disjoint_supports (l: {set {perm T}}):=
  trivIset [set support C| C in l] /\ {in l &, injective support}.

Lemma disjoint_cycle_dec s:
  disjoint_supports (cycle_dec s).
Proof.
  split.
  - have:= partition_support s; rewrite -support_cycle_dec.
    by rewrite /partition => /and3P [].
  - move => C1 C2 /imsetP [c1 Hc1 ->] /imsetP [c2 HC2 ->].
    by rewrite !support_restr_perm // => ->.
Qed.

Lemma support_disjointC s t :
  [disjoint support s & support t] -> (s * t = t * s)%g.
Proof.
  move=> Hdisj; apply/permP => x; rewrite !permM.
  case: (boolP (x \in support s)) => [Hs |].
  - have:= Hdisj; rewrite disjoints_subset => /subsetP H.
    have:= H x Hs; rewrite inE in_support negbK => /eqP ->.
    move: Hs; rewrite support_stable => /H.
    by rewrite inE in_support negbK => /eqP ->.
  - rewrite in_support negbK => /eqP Hs; rewrite Hs.
    case: (boolP (x \in support t)) => [Ht |].
    + move: Ht; rewrite support_stable.
      move: Hdisj; rewrite -setI_eq0 setIC setI_eq0 disjoints_subset => /subsetP.
      by move=> H/H{H}; rewrite inE in_support negbK => /eqP ->.
    + by rewrite in_support negbK => /eqP ->; rewrite Hs.
Qed.

Lemma abelian_disjoint_supports (A : {set {perm T}}) :
  disjoint_supports A -> abelian <<A>>.
Proof.
  move=> [] /trivIsetP Htriv Hinj.
  rewrite abelian_gen abelianE; apply/subsetP => C HC.
  apply/centP => D HD.
  case: (altP (C =P D)) => [-> // | HCD].
  apply support_disjointC.
  apply Htriv; try exact: mem_imset.
  move: HCD; apply contra => /eqP Hsupp; apply /eqP.
  exact: Hinj.
Qed.

Lemma abelian_cycle_dec s : abelian <<cycle_dec s>>.
Proof.
  apply abelian_disjoint_supports.
  exact: disjoint_cycle_dec.
Qed.

Lemma restr_perm_inj s : {in psupport s &, injective ((restr_perm (T:=T))^~ s)}.
Proof.
  by move=> C D /support_restr_perm {2}<- /support_restr_perm {2}<- ->.
Qed.



Lemma out_perm_prod_seq (A: seq {perm T}) x:
  {in A, forall C, x \notin support C} -> (\prod_(C <- A) C)%g x = x.
Proof.
  elim: A => [_ | a l Hl Hal]; first by rewrite big_nil perm1.
  rewrite big_cons permM.
  have:= Hal _ (mem_head a l); rewrite in_support negbK => /eqP ->.
  rewrite Hl // => C HC.
  by apply Hal; rewrite in_cons HC orbT.
Qed.

Lemma out_perm_prod (A: {set {perm T}}) x:
  {in A, forall C, x \notin support C} -> (\prod_(C in A) C)%g x = x.
Proof.
  move=> H; rewrite big_enum; apply out_perm_prod_seq.
  move=> C; rewrite mem_enum; exact: H.
Qed.

Lemma out_of_disjoint (A : {set {perm T}}) C x :
  disjoint_supports A ->
  C \in A ->
  x \in support C ->
  {in A :\ C, forall C0, x \notin support C0}.
Proof.
  rewrite /disjoint_supports => [] [/trivIsetP Hdisj Hinj] HC Hx C0.
  rewrite 2!inE => /andP [] HC0 HC0A.
  move/(_ (support C) (support C0) (mem_imset _ HC) (mem_imset _ HC0A)): Hdisj.
  have Hdiff: support C != support C0.
    by move: HC0; apply contra => /eqP/Hinj ->.
  move => /(_ Hdiff) /disjoint_setI0 /setP /(_ x).
  rewrite inE in_set0 => /nandP [] //.
  by move => /negbTE; rewrite Hx.
Qed.

Import finmodule.FiniteModule morphism.

Lemma prod_of_disjoint (A : {set {perm T}}) C x:
  disjoint_supports A -> C \in A ->
  x \in support C -> (\prod_(C0 in A) C0)%g x = C x.
Proof.
  move=> Hdisj HC Hx.
  have {Hx} Hnotin := out_of_disjoint Hdisj HC Hx.
  have Hin : forall i : {perm T}, (i \in A) && (i != C) -> i \in <<A>>%g.
    move => c /andP [Hi _]; exact: mem_gen.
  have abel := abelian_disjoint_supports Hdisj.
  rewrite [X in fun_of_perm X](_ :
      _ = val (\sum_(C0 in A) fmod abel C0)%R); first last.
    rewrite -morph_prod; last by move=> i; exact: mem_gen.
    rewrite -[LHS](fmodK abel) //.
    by apply group_prod => i; exact: mem_gen.
  rewrite (bigD1 C) //= GRing.addrC -morph_prod //=.
  rewrite -fmodM /=; [ | exact: group_prod | exact: mem_gen].
  rewrite fmodK; first last.
    apply groupM; last exact: mem_gen.
    exact: group_prod.
  rewrite {abel Hin Hdisj HC} permM; congr fun_of_perm.
  apply big_rec; first by rewrite perm1.
  move=> i S Hi {2}<-; rewrite permM; congr fun_of_perm.
  apply/eqP; rewrite -[_ == _]negbK -in_support.
  by apply Hnotin; rewrite !inE andbC.
Qed.

Lemma expg_prod_of_disjoint (A : {set {perm T}}) C0 x i:
  C0 \in A ->
  disjoint_supports A -> x \in support C0 ->
  ((\prod_(C in A) C)^+i)%g x = (C0^+i)%g x.
Proof.
  move => HC0 Hdisj Hx.
  have Hin j : (C0 ^+j)%g x \in support C0.
    elim j => [|k Hk]; first by rewrite expg0 perm1.
    by rewrite expgSr permM -support_stable.
  elim: i => [|j Hj].
  - by rewrite !expg0 perm1.
  - by rewrite !expgSr !permM Hj (prod_of_disjoint Hdisj HC0 (Hin j)).
Qed.

Lemma cycle_decE s : (\prod_(C in cycle_dec s) C)%g = s.
Proof.
  apply /permP => x.
  case: (boolP (x \in support s)) => Hx; first last.
  - rewrite out_perm_prod.
    + by move: Hx; rewrite in_support negbK => /eqP ->.
    + move=> Ctmp /imsetP [C] HC -> {Ctmp}.
      rewrite (support_restr_perm HC).
      move: Hx; apply contra => Hx.
      have:= partition_support s => /and3P [] /eqP <- _ _.
      by apply/bigcupP; exists C.
  have Hcy : pcycle s x \in psupport s.
    by rewrite inE mem_imset //= support_card_pcycle.
  rewrite (prod_of_disjoint (C := restr_perm (pcycle s x) s)).
  - rewrite restr_permE //; last exact: pcycle_id.
    exact: psupport_astabs.
  - exact: disjoint_cycle_dec.
  - by apply/imsetP; exists (pcycle s x).
  - rewrite support_restr_perm //; exact: pcycle_id.
Qed.

Lemma disjoint_supports_of_decomp (A : {set {perm T}}) (B : {set {perm T}}):
  disjoint_supports A -> disjoint_supports B ->
    (\prod_(C in A) C)%g = (\prod_(C in B) C)%g ->
    {in A, forall c1, {in B, forall c2, support c1 = support c2 -> c1 = c2}}.
Proof.
  move=> HdisjA HdisjB /permP Heq c1 Hc1 c2 Hc2 /setP Hsupp.
  apply/permP => x.
  case (boolP (x \in support c1)) => H0;
  have := H0; rewrite {}Hsupp;  have := H0 => {H0}.
  - move => Hx1 Hx2; move/(_ x): Heq.
    by rewrite (prod_of_disjoint _ Hc1) ?(prod_of_disjoint _ Hc2).
  - by rewrite !in_support !negbK => /eqP -> /eqP ->.
Qed.


Lemma disjoint_supports_cycles (A: {set {perm T}}):
  {in A, forall C, is_cycle C} ->
    disjoint_supports A ->
    {in A, forall C, support C \in pcycles (\prod_(C in A) C)%g}.
Proof.
  move=> Hcycle Hdisj C HC; move/(_ C HC): Hcycle.
  rewrite /is_cycle => /cards1P [X] Hpsupp.
  have:= eqxx X; rewrite -in_set1 -Hpsupp inE => /andP [/imsetP [x _] Hx].
  subst X; rewrite pcycleE=> Hcard.
  have:= cover_partition (partition_support C); rewrite Hpsupp.
  rewrite /cover big_set1 => <-; apply /imsetP; exists x => //.
  have Hx : x \in support C.
    rewrite in_support; apply /eqP; rewrite -apermE => /afix1P.
    rewrite -afix_cycle => /orbit1P Hcontra.
    by move: Hcard; rewrite Hcontra cards1.
  apply/setP => y; apply /pcycleP/pcycleP => [] [i] ->;
    exists i; apply esym; by rewrite (expg_prod_of_disjoint i HC).
Qed.


Lemma disjoint_supports_pcycles (A: {set {perm T}}):
  {in A, forall C, is_cycle C} ->
    disjoint_supports A ->
    {in psupport (\prod_(C in A) C)%g, forall X, exists C, C \in A /\ support C = X}.
Proof.
  move => Hcycle Hdisj X; rewrite inE => /andP [/imsetP [x] _ -> {X} Hcard].
  case: (boolP (x \in (support (\prod_(C in A) C)%g))) => [Hin|].
  - have: exists2 C0, (C0 \in A) & (x \in support C0).
      apply /exists_inP.
      move: Hin; apply contraLR; rewrite negb_exists => /forallP Hnotin.
      rewrite in_support negbK; apply /eqP; apply out_perm_prod => C HC.
      by have:= Hnotin C; rewrite HC andTb.
    move => [C0] HC0 Hx.
    exists C0; split => //; move: Hx.
    have: support C0 \in (pcycles (\prod_(C in A) C)).
      exact: disjoint_supports_cycles.
    move => /imsetP [y] _ ->.
    by rewrite -eq_pcycle_mem => /eqP.
  - rewrite in_support negbK pcycleE -apermE => /eqP /afix1P.
    rewrite -afix_cycle => /orbit1P.
    rewrite -pcycleE => Hcontra; move: Hcard.
    by rewrite Hcontra cards1.
Qed.


Lemma uniqueness_cycle_dec (A : {set {perm T}}) s:
  {in A, forall C, is_cycle C} ->
    disjoint_supports A ->
    (\prod_(C in A) C)%g = s ->
    A = cycle_dec s.
Proof.
  move => Hcy Hdisj Hprod.
  apply /setP => C; apply/idP/imsetP.
  - move=> HC; have:= HC => /disjoint_supports_cycles.
    move=> /(_ Hcy Hdisj) /imsetP [x _]; rewrite Hprod => Hsupp.
    have Hx: pcycle s x \in psupport s.
      rewrite inE; apply /andP; split.
      + by apply /imsetP; exists x.
      + by rewrite -Hsupp; rewrite card_support_noteq1.
    exists (pcycle s x) => //.
    have:= disjoint_supports_of_decomp Hdisj (disjoint_cycle_dec s).
    rewrite Hprod cycle_decE => /(_ erefl C HC (restr_perm (pcycle s x) s)).
    apply; last by rewrite support_restr_perm.
    by apply /imsetP; exists (pcycle s x).
  - rewrite -{1}Hprod => [] [X HX1] ->.
    have:= disjoint_supports_pcycles Hcy Hdisj HX1.
    move=> [x] [] Hx; rewrite -{1}(support_restr_perm HX1).
    move=> /(disjoint_supports_of_decomp Hdisj (disjoint_cycle_dec s)).
    rewrite Hprod cycle_decE => /(_ erefl Hx) <- //.
    by apply /imsetP; exists X; rewrite -?Hprod.
Qed.



End PermCycles.

Section Ordergeq.

Lemma geq_total : total geq.
Proof.
  admit.
Admitted.

Lemma geq_trans : transitive geq.
Proof.
  admit.
Admitted.

Lemma anti_geq : antisymmetric geq.
Proof.
  admit.
Admitted.
End Ordergeq.


Section cycle_type.
Variable T : finType.
Implicit Types (s t : {perm T}) (n : nat).

Definition set_partition_shape (s : {set {set T}}) :=
  sort geq [seq #|(x: {set T})| | x <- enum s].

Lemma is_part_sortedE sh :
  (is_part sh) = (sorted geq sh) && (0 \notin sh).
Proof.
  apply/idP/andP => [Hpart|].
  - split.
    + apply/sorted1P => i _.
      by move: Hpart=> /is_partP [_]; apply.
    + move: Hpart; elim: sh => [// | s0 sh IHsh] Hpart.
      rewrite inE negb_or eq_sym.
      have /= -> /= := (part_head_non0 Hpart).
      by apply IHsh; move: Hpart => /andP [].
  - move=> [/sorted1P Hsort Hnotin].
    apply/is_partP; split => [| i].
    + case: sh Hnotin {Hsort} => [// | s0 sh].
      rewrite inE negb_or eq_sym => /andP [Hs0 Hnot] /=.
      elim: sh s0 Hs0 Hnot => [// | s1 sh IHsh] s0 _.
      rewrite inE negb_or eq_sym /= => /andP [].
      exact: IHsh.
    + case: (ltnP i.+1 (size sh)) => Hsz; first exact: Hsort.
      by rewrite (nth_default _ Hsz).
Qed.

Lemma set_partition_shapeP (s : {set {set T}}) D :
  partition s D -> is_part_of_n #|D| (set_partition_shape s).
Proof.
  rewrite /set_partition_shape => /and3P [/eqP Hcov Htriv Hnon0].
  rewrite /is_part_of_n /= is_part_sortedE.
  apply/and3P; split.
  - have:= perm_sort geq  [seq #|(x: {set T})| | x <- enum s].
    move=> /perm_eqlP/perm_sumn ->.
    rewrite -sumnE big_map -big_enum.
    move: Htriv; rewrite /trivIset => /eqP ->.
    by rewrite Hcov.
  - apply sort_sorted => m n /=; exact: leq_total.
  - move: Hnon0; apply contra.
    rewrite mem_sort => /mapP [] x.
    by rewrite mem_enum => Hx /esym/cards0_eq <-.
Qed.

Definition cycle_type_seq (s : {perm T}) := set_partition_shape (pcycles s).

Definition card_support_cycles (s : {perm T}) :=
  [seq #|(C : {set T})| | C in (support_cycles s)].


Lemma cycle_type_partn s:
  is_part_of_n #|T| (cycle_type_seq s).
Proof.
  rewrite /cycle_type_seq -cardsT; apply set_partition_shapeP.
  exact: partition_pcycles.
Qed.

Lemma cycle_type_dec (s : {perm T}) :
  let l := sort geq (card_support_cycles s) in
  cycle_type_seq (s : {perm T}) = l ++ (nseq (#|T| - sumn l) 1).
Proof.
  move => l.
  admit.
Admitted.

Definition cycle_type (s : {perm T}) := IntPartN (cycle_type_partn s).

Lemma support_cycle_type s t :
  perm_eq (card_support_cycles s) (card_support_cycles t) ->
    cycle_type s = cycle_type t.
Proof.
  move => Heq; apply val_inj => /=; rewrite !cycle_type_dec.
  suff -> : sort geq (card_support_cycles s) =
            sort geq (card_support_cycles t) by [].
  apply /perm_sortP => //.
  - exact: geq_total.
  - exact: geq_trans.
  - exact: anti_geq.
Qed.

Lemma conjg_cycle s a :
  (<[s]> :^ a = <[s ^ a]>)%g.
Proof.
  apply /setP => x.
  apply /imsetP/cycleP => [[x0 /cycleP [i] ->] ->|[i] ->].
  - by exists i; exact: conjXg.
  - by exists (s ^+i)%g; [apply /cycleP; exists i|rewrite conjXg].
Qed.

Lemma pcycle_conjg s a x :
  pcycle ((s ^ a)%g) (a x) = [set a y | y in pcycle s x].
Proof.
  rewrite !pcycleE; apply /setP => y.
  apply /idP/imsetP => [|[x0] Hx0 ->].
  - rewrite -conjg_cycle => Hy.
    exists ((a ^-1)%g y); last by rewrite permKV.
    move: Hy; rewrite {1}(_: y = a ((a ^-1)%g (y))); last by rewrite permKV.
    by rewrite -{1}apermE orbit_conjsg.
  - by rewrite -conjg_cycle -apermE orbit_conjsg.
Qed.


Lemma pcycles_conjg s a :
  pcycles (s ^ a)%g = [set [set a y | y in (X : {set T})] | X in pcycles s].
Proof.
  apply /setP => X0.
  apply /imsetP/imsetP => [[x _]|[x /imsetP [x0 _] ->] ->].
  - rewrite (_: x = a ((a ^-1)%g (x))); last by rewrite permKV.
    rewrite pcycle_conjg => ->.
    exists (pcycle s ((a^-1)%g x)) => //.
    by apply /imsetP; exists ((a^-1)%g x).
  - exists (a x0) => //.
    by rewrite pcycle_conjg.
Qed.

Require Import ordcast. (* for imset_inj TODO : move in tools *)

Lemma cycle_type_of_conjg s a:
  cycle_type s = cycle_type (s ^ a)%g.
Proof.
  apply val_inj => /=.
  rewrite /cycle_type_seq.
  rewrite pcycles_conjg; apply /(perm_sortP geq_total geq_trans anti_geq).
  rewrite (_ : [seq _ | x <- _] =
               [seq #|[set a y | y in (x : {set T})]| | x <- enum (pcycles s)]);
    last by apply eq_map => x;  apply esym; apply card_imset; exact: perm_inj.
  - rewrite (map_comp (fun x : {set T} => #|x|)); apply perm_map.
    apply uniq_perm_eq.
    + rewrite map_inj_uniq; first exact: enum_uniq.
      apply imset_inj; exact: perm_inj.
    + exact: enum_uniq.
    + move=> x; rewrite mem_enum.
      apply/mapP/imsetP => [] [x0].
      * by rewrite mem_enum => Hx0 -> {x}; exists x0.
      * by move=> Hx0 -> {x}; exists x0; rewrite ?mem_enum.
Qed.

Lemma conjg_of_cycle s a:
  is_cycle s -> is_cycle (s ^ a)%g.
Proof.
  move => /cards1P [X] HX.
  apply /cards1P; exists [set a x | x in X].
  apply /setP => y.
  rewrite !inE.
  apply /andP/eqP => [| -> ]; rewrite pcycles_conjg.
  - move => [][/imsetP [Y HY ->]].
    rewrite card_imset => Hcard; last by exact: perm_inj.
    have: Y \in psupport s by  rewrite inE; apply /andP.
    by rewrite HX inE => /eqP ->.
  - have: X \in [set X] by rewrite inE.
    rewrite -{}HX inE => /andP [HX1 HX2].
    split; first by apply /imsetP; exists X.
    by rewrite card_imset //; exact: perm_inj.
Qed.

Lemma support_conjg s a:
  support (s ^ a) = [set a x | x in support s].
Proof.
  apply /setP => x.
  rewrite in_support; apply /idP/imsetP => [|[x0]].
  - rewrite conjgE !permM => /eqP Hx.
    exists (a^-1 x)%g; last by rewrite -permM mulVg perm1.
    rewrite in_support; apply /eqP => Hx'.
    by move : Hx; rewrite Hx'; rewrite -permM mulVg perm1.
  - rewrite in_support => Hx0 ->.
    rewrite conjgE -!permM mulKVg permM.
    move: Hx0; apply contra => /eqP Hx0.
    by apply /eqP; apply (perm_inj Hx0).
Qed.


Lemma card_support_conjg s a:
  #|support s| = #|support (s ^ a)%g|.
Proof.
  rewrite support_conjg.
  apply esym; apply card_imset.
  by exact: perm_inj.
Qed.

Lemma disjoint_imset (f: T -> T) (A B : {set T}):
  injective f ->
  [disjoint A & B] -> [disjoint [set f x | x in A] & [set f x | x in B]].
Proof.
  rewrite -!setI_eq0 => Hinj /eqP Hdisj.
  rewrite -imsetI; last by move=> x y _ _; exact: Hinj.
  by rewrite imset_eq0 Hdisj.
Qed.

Lemma conjg_of_disjoint_supports (A : {set {perm T}}) a:
  disjoint_supports A -> disjoint_supports [set (s ^ a)%g | s in A].
Proof.
  move => [/trivIsetP Hdisj Hinj].
  split => [|x1 x2 /imsetP [s1 Hs1 ->] /imsetP [s2 Hs2 ->]].
  - apply /trivIsetP => B1 B2.
    move => /imsetP [x1 /imsetP [s1 Hs1 ->] -> {x1}].
    move => /imsetP [x2 /imsetP [s2 Hs2 ->] -> {x2}].
    rewrite !support_conjg => Hdiff.
    apply disjoint_imset; first exact: perm_inj.
    apply: Hdisj; try exact: mem_imset.
    by move: Hdiff; apply contra => /eqP ->.
  - rewrite !support_conjg => Hsupp.
    rewrite (_ : s1 = s2) //; apply Hinj => //.
    apply /setP => x; apply /idP/idP => Hx.
    + have:= mem_imset a Hx.
      by rewrite Hsupp => /imsetP [y] Hy /perm_inj ->.
    + have:= mem_imset a Hx.
      by rewrite -Hsupp => /imsetP [y] Hy /perm_inj ->.
Qed.

Import finmodule.FiniteModule morphism.

Lemma cycle_dec_of_conjg s a:
  [set (c ^ a)%g | c in cycle_dec s] = cycle_dec (s ^ a)%g.
Proof.
  have abel : abelian <<[set (c ^ a)%g | c in cycle_dec s]>>.
    apply abelian_disjoint_supports.
    apply: conjg_of_disjoint_supports.
    exact: disjoint_cycle_dec.
  apply: uniqueness_cycle_dec => [x /imsetP [x0 Hx0 ->]||].
  - apply: conjg_of_cycle; apply: is_cycle_dec.
    exact: Hx0.
  - apply: conjg_of_disjoint_supports.
    exact: disjoint_cycle_dec.
  - rewrite [LHS](_ : _ =
      val (\sum_(i in [set (c ^ a)%g | c in cycle_dec s]) fmod abel i)%R);
      first last.
      rewrite -(morph_prod [morphism of fmod abel]);
        last by move=> i; exact: mem_gen.
      rewrite -[LHS](fmodK abel) //.
      by apply group_prod => i; exact: mem_gen.
    rewrite big_imset /=; last by move=> x y _ _; exact: conjg_inj.
    rewrite -(morph_prod [morphism of fmod abel]); first last.
      move=> i Hi; apply mem_gen; exact: mem_imset.
    rewrite fmodK; first last.
      apply group_prod => i Hi; apply mem_gen; exact: mem_imset.
    by rewrite -conjg_prod cycle_decE.
Qed.

(* Ici il faut ayant supposé cycle_type s = cycle_type t, construire un
bijection entre pcycles s et pcycles t *)

Definition slice_part (P : {set {set T}}) :=
 SlicedSet set0 P (fun x : {set T} => #|x|).

Definition slpcycles s := slice_part (pcycles s).

Lemma slice_slpcycleE s i :
  #|slice (slpcycles s) i| = count_mem i (cycle_type s).
Proof.
  rewrite /cycle_type /slice /cycle_type_seq /set_partition_shape /=.
  rewrite [RHS](_ : _ =
      (count_mem i) [seq #|(x : {set _})| | x <- enum (pcycles s)]);
      last by apply/perm_eqP/perm_eqlP; exact: perm_sort.
  rewrite cardE /enum_mem -enumT /=.
  rewrite size_filter count_map count_filter.
  apply eq_count => C /=; apply/imsetP/idP => [[X] | HC].
  - by rewrite inE andbC => H ->.
  - by exists C => //; rewrite inE andbC.
Qed.

Lemma cycle_type_eq s t:
  cycle_type s = cycle_type t ->
    forall i, #|slice (slpcycles s) i| = #|slice (slpcycles t) i|.
Proof. by move=> H i; rewrite !slice_slpcycleE H. Qed.

Definition conjg_pcycles s t :=
  bij (U := slpcycles s) (slpcycles t).

Lemma conjg_pcyclesP s t:
  cycle_type s = cycle_type t ->
  [/\ {in slpcycles s &, injective (conjg_pcycles (s := s) t)},
   [set (conjg_pcycles t x) | x in (slpcycles s)] = slpcycles t &
   {in (slpcycles s), forall x, #|(conjg_pcycles t x)| = #|x| } ].
Proof. by move => /cycle_type_eq; exact: bijP. Qed.


Lemma exp_pcycle s x : (s ^+ #|pcycle s x|)%g x = x.
Proof. rewrite permX; exact: iter_pcycle. Qed.

Lemma expM_pcycle s x i : (s ^+ (i * #|pcycle s x|))%g x = x.
Proof.
  elim: i => [//= | i IHi]; first by rewrite mul0n expg0 perm1.
  by rewrite mulSn expgD permM exp_pcycle.
Qed.

From mathcomp Require Import div.

Lemma pcycle_mod s x i:
  (s ^+ i)%g x = (s ^+ (i %% #|pcycle s x|))%g x.
Proof. by rewrite {1}(divn_eq i #|pcycle s x|) expgD permM expM_pcycle. Qed.

Lemma eq_in_pcycle s x i j :
  ((s ^+ i)%g x == (s ^+ j)%g x) = (i == j %[mod #|pcycle s x|]).
Proof.
  apply/idP/idP.
  - rewrite [X in X == _]pcycle_mod [X in _ == X]pcycle_mod !permX.
    have HC : 0 < #|pcycle s x|.
      rewrite card_gt0; apply/set0Pn; exists x; exact: pcycle_id.
    rewrite -!(nth_traject _ (ltn_pmod _ HC)).
    rewrite nth_uniq // ?size_traject ?ltn_pmod //.
    exact: uniq_traject_pcycle.
  - by move=> /eqP H; apply/eqP; rewrite [LHS]pcycle_mod [RHS]pcycle_mod H.
Qed.

(*
Lemma eq_pcycle s x i :
  ((s ^+ i)%g x == x) = (i == 0 %[mod #|pcycle s x|]).
Proof. by rewrite -{2}(perm1 x) -(expg0 s) eq_in_pcycle. Qed.
*)

Definition canpcycle s x := odflt x [pick y in pcycle s x].

Lemma canpcycleP s x : x \in pcycle s (canpcycle s x).
Proof.
  rewrite /canpcycle /= pcycle_sym.
  case: pickP => [x0 //|].
  by move => /(_ x) /=; rewrite pcycle_id.
Qed.

Lemma canpcycleE s x y :
  x \in pcycle s y -> canpcycle s x = canpcycle s y.
Proof.
  move=> H; have:= H; rewrite /canpcycle -eq_pcycle_mem => /eqP ->.
  case: pickP => [x0 //|].
  by move => /(_ y) /=; rewrite pcycle_id.
Qed.

Lemma pcycleE (s: {perm T}) x y :
  y \in pcycle s x -> exists i, y == (s ^+ i)%g x.
Proof.
  move=> /pcycleP H.
  move: H => [i Hi]; exists i; by rewrite Hi.
Qed.

Definition indpcycle s (x : T) : nat := ex_minn (pcycleE (canpcycleP s x)).

Lemma indpcycleP s x : ((s ^+ (indpcycle s x)) (canpcycle s x))%g = x.
Proof. rewrite /indpcycle; by case: ex_minnP => i /eqP. Qed.

(* Retourne le cycle  de l'image de x *)
Definition imcycle s t :=
  let pbij := (@conjg_pcycles s t) in
  fun (x : T) => pbij (pcycle s x).

(* Retourne le canonique de l'image de x *)
Definition conjbijcan s t x :=
    odflt x [pick y in imcycle s t x].

Definition conjbij s t x :=
    ((t ^+ (indpcycle s x)) (conjbijcan s t x))%g.

Section EqCycleType.

Variable s t : {perm T}.
Hypothesis Heq : cycle_type s = cycle_type t.

Lemma mem_imcycle x : imcycle s t x \in pcycles t.
Proof.
  move: Heq => /conjg_pcyclesP [] /= _ Himage _.
  by rewrite -Himage /imcycle; apply mem_imset; apply mem_imset.
Qed.

Lemma imcycle_perm x : imcycle s t (s x) = imcycle s t x.
Proof. by rewrite /imcycle pcycle_perm1. Qed.

Lemma pcycle_conjbijcan x : pcycle t (conjbijcan s t x) = imcycle s t x.
Proof.
  rewrite /conjbijcan /=.
  have:= mem_imcycle x => /imsetP [y0 _ ->].
  case: pickP => [/= y|].
  - by rewrite -eq_pcycle_mem => /eqP ->.
  - by move=> /(_ y0); rewrite pcycle_id.
Qed.

Lemma card_imcycle x : #|imcycle s t x| = #|pcycle s x|.
Proof.
  rewrite /imcycle.
  move: Heq => /conjg_pcyclesP [_ _ /=]; apply.
  exact: mem_imset.
Qed.

Lemma conjbijcanE x :
  conjbijcan s t (s x) = conjbijcan s t x.
Proof.
  rewrite /conjbijcan imcycle_perm.
  have:= mem_imcycle x => /imsetP [y0 _ ->].
  by case: pickP => // /(_ y0); rewrite pcycle_id.
Qed.

Lemma conjbijcan_expE x i :
  conjbijcan s t ((s ^+ i)%g x) = conjbijcan s t x.
Proof.
  elim: i => [// | i IHi]; first by rewrite expg0 perm1.
  by rewrite expgSr permM conjbijcanE.
Qed.

Lemma conjbijP x : conjbij s t (s x) = t (conjbij s t x).
Proof.
  rewrite /conjbij conjbijcanE.
  have := card_imcycle x; rewrite -pcycle_conjbijcan.
  move: (conjbijcan s t x) => y H.
  apply/eqP; rewrite -permM -expgSr eq_in_pcycle {}H.
  have:= canpcycleP s x; rewrite -eq_pcycle_mem => /eqP ->.
  rewrite -eq_in_pcycle.
  rewrite expgSr permM indpcycleP.
  have:= mem_pcycle s 1 x; rewrite expg1 => /canpcycleE <-.
  by rewrite indpcycleP.
Qed.

Lemma conjbijcanP x : conjbijcan s t x = canpcycle t (conjbij s t x).
Proof.
  rewrite /conjbij /conjbijcan /canpcycle pcycle_perm.
  set defim := odflt _ _.
  have:= erefl defim; rewrite {1 3 4 5}/defim.
  case: pickP => [im Him | Habs] /=.
  - rewrite {}/defim => Hdefim.
    rewrite /canpcycle (_ : [pick y in  _] = some im) //.
    rewrite [LHS](_ : _ = [pick y in imcycle s t x]); first last.
      apply eq_pick => y /=; congr (y \in _).
      have:= mem_imcycle x => /imsetP [y0 _ Hy0].
      by move: Him; rewrite Hy0 /= -eq_pcycle_mem => /eqP ->.
    rewrite Hdefim.
    by case: pickP => // /(_ im); rewrite Him.
  - exfalso; move: Habs.
    have:= mem_imcycle x => /imsetP [y _ ->] /(_ y).
    by rewrite pcycle_id.
Qed.

Lemma indpcycle_conjbij x :
   indpcycle t (conjbij s t x) = indpcycle s x.
Proof.
  apply eq_ex_minn => i.
  rewrite {1}/conjbij -conjbijcanP eq_in_pcycle pcycle_conjbijcan card_imcycle.
  rewrite -{4}(indpcycleP s x) eq_in_pcycle.
  suff -> : pcycle s x = pcycle s (canpcycle s x) by [].
  apply/eqP; rewrite eq_pcycle_mem; exact: canpcycleP.
Qed.

End EqCycleType.


Lemma conjbijK s t :
  cycle_type s = cycle_type t -> cancel (conjbij s t) (conjbij t s).
Proof.
  rewrite /conjbij => Heq x; have Heqs := esym Heq.
  rewrite conjbijcan_expE //.
  have -> : (conjbijcan t s (conjbijcan s t x)) = canpcycle s x.
    rewrite conjbijcanP //; apply canpcycleE.
    rewrite /conjbij -eq_pcycle_mem pcycle_perm.
    rewrite pcycle_conjbijcan //.
    rewrite /imcycle pcycle_conjbijcan // /imcycle.
    rewrite /conjg_pcycles bijK //=.
    - move=> i; exact: cycle_type_eq.
    - exact: mem_imset.
  suff -> : indpcycle t ((t ^+ indpcycle s x)%g (conjbijcan s t x)) =
            indpcycle s x.
    by rewrite indpcycleP.
  by rewrite -/(conjbij s t x) indpcycle_conjbij.
Qed.

Lemma conjbij_inj s t : cycle_type s = cycle_type t -> injective (conjbij s t).
Proof. move=> /conjbijK H; exact: can_inj. Qed.



(* COMMENT ========================================================== *)

  (*Définir la conjugaison sur les pcycles : partir de x, choisir un élément y de f (pcycle s x) {Cet ensemble est non vide, par égalité des cardinaux}, on pose arbitrairement f x = y, et on renvoie f s^i x = t^i y, on épuise ainsi tous les éléments de (pcycle s x), et la fonction est correctement définie *)
(*Definition conjg_on_pcycle s x :=*)

(*
Lemma bla1 s t :
  cycle_type s = cycle_type t ->
  exists f : T -> T,
    injective f /\
    forall x, f (s x) = t (f x).
Proof.
Admitted.
*)

Lemma classes_of_permP s t:
  reflect (t \in (s ^: [set: {perm T}])%g) (cycle_type s == cycle_type t).
Proof.
  apply (iffP eqP).
  move=> /bla1.
  => [/bla1 [f] [Hinj Hcom]|]. /imsetP [a] _ ->].
  - apply /imsetP; exists (perm (Hinj)); rewrite ?inE //.
    apply /permP => x; rewrite conjgE !permM permE.
    have:= (Hcom (((perm Hinj)^-1)%g x)).
    have -> : f (((perm Hinj)^-1)%g x) = (perm Hinj) (((perm Hinj)^-1)%g x).
      by rewrite -permE.
    by rewrite permKV.
  -  by exact: cycle_type_of_conjg.
Qed.


(* Lemma cycle_type réalise une bijection de classes [set: {perm T}] sur enum_partn (#|T|) *)

(*
The action of the permutation (n, n+1, ... ,n+l-1) on (enum T)
*)

Definition cyclefun_of (n l : nat) : T -> T :=
  fun x =>
    let i := index x (enum T) in
    if n <= i < n+l-1 then (nth x (enum T) (i+1))
    else if i == n+l-1 then (nth x (enum T) n)
         else x.

Lemma injective_cyclefun_of n l:
  injective (cyclefun_of n l).
Proof.
  move => x1 x2.
  rewrite /cyclefun_of.
  case: leqP; rewrite ?andbT ?andbF.
      case: (boolP (n <= index x2 (enum T) < n+l-1)).
  admit.
Admitted.

Definition cycle_of n l : {perm T} :=
  perm (@injective_cyclefun_of n l).

Lemma cycle_ofP n l : n + l <= #|T| -> is_cycle (cycle_of n l).
Proof.
  admit.
Admitted.

Lemma support_cycle_of n l :
  n + l <= #|T| ->
    (support (cycle_of n l) = [set x | n <= index x (enum T) <= n+l-1]).
Proof.
  admit.
Admitted.

Definition cycle_dec_of_part (part : seq nat) : seq {perm T} :=
  let pp := [seq i | i <- part & i > 1] in
  mkseq (fun i => cycle_of (part_sum pp i) (nth 0 pp i)) (size pp).
(*
Fixpoint perm_of_part_rec (part : seq nat) (n : nat) : seq {perm T} :=
  match part with
  | [::] => [::]
  | a :: l1 =>
    if a == 1 then (perm_of_part_rec l1 n.+1)
    else (cycle_of n a) :: (perm_of_part_rec l1 (a + n))
  end.

*)

Definition parts_of_part (part : seq nat) : {set {set T}} :=
  [set C in [seq [set x in X] | X <- reshape part (enum T)]].

(*
Definition parts_of_part (part : seq nat) : {set {set T}} :=
  \bigcup_(S in [seq [set x in X] | X <- reshape part (enum T)]) [set S].

Definition parts_of_part (part : seq nat) : {set {set T}} :=
  \bigcup_(X <- reshape part (enum T)) [set [set x in X]].

Definition parts_of_part (part : seq nat) : {set {set T}} :=
  [set [set x in (X : seq T)] | X in reshape part (enum T)].
  \prod_(c <- cycle_dec_of_part part) c.
*)

Definition perm_of_part (part : seq nat) : {perm T} :=
  \prod_(c <- cycle_dec_of_part part) c.


Lemma perm_of_part_recP (part : intpartn #|T|) c :
  c \in perm_of_part_rec part 0 -> exists n l, n+l <= #|T| /\ c = cycle_of n l.
Proof.
  admit.
Admitted.


Lemma blabla (part : intpartn #|T|) :
  [set i in perm_of_part_rec part 0] = cycle_dec (perm_of_part part).
Proof.
  apply uniqueness_cycle_dec => [C||]; last rewrite /perm_of_part.
  - by rewrite inE => /perm_of_part_recP [n [l [/cycle_ofP Hcy] ->]].
  - split.
    + apply /trivIsetP => A B.
      move => /imsetP [CA]; rewrite inE => /perm_of_part_recP [n1 [l1 [H1 ->] ->]].
      move => /imsetP [CB]; rewrite inE => /perm_of_part_recP [n2 [l2 [H2 ->] ->]].
      rewrite !support_cycle_of //.
      admit. (*besoin de plus de précisions sur qui sont n et l, par rapport a la partition initiale*)
    + move => C1 C2.
      rewrite inE => /perm_of_part_recP [n1 [l1 [H1 ->]]]. 
      rewrite inE => /perm_of_part_recP [n2 [l2 [H2 ->]]]. 
      rewrite !support_cycle_of // => /setP Heq.
      have : n1 = n2 /\ l1 = l2.
        admit.
      by move => [-> ->].
  - admit. (*big_imset, encore ...*)
Admitted.

Lemma perm_of_partE (part : intpartn #|T|) : cycle_type (perm_of_part part) = part.
Proof.
  admit.
Admitted.

======================= *)
End cycle_type.
