/**
 * @file shiftview.c
 * @brief Command for shifting the viewed tags.
 *
 * @author Fernando C.V.
 * @see http://lists.suckless.org/dev/1104/7590.html
 *
 * This file is included by dwm.c and is not compiled on its own.
 */
/**
 * @brief Shift the viewed tags left or right, wrapping around.
 *
 * @param arg        Number of tags to shift; negative shifts left.
 */
void shiftview(const Arg* arg) {
  Arg shifted;

  if (arg->i > 0)  // left circular shift
    shifted.ui = (selmon->tagset[selmon->seltags] << arg->i) |
                 (selmon->tagset[selmon->seltags] >> (LENGTH(tags) - arg->i));

  else  // right circular shift
    shifted.ui = selmon->tagset[selmon->seltags] >> (-arg->i) |
                 selmon->tagset[selmon->seltags] << (LENGTH(tags) + arg->i);

  view(&shifted);
}
