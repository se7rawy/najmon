import { fromJS } from 'immutable';

import type { StatusLike } from '../hashtag_bar';
import { computeHashtagBarForStatus } from '../hashtag_bar';

function createStatus(content: string, hashtags: string[]) {
  return fromJS({
    tags: hashtags.map((name) => ({ name })),
    contentHtml: content,
  }) as unknown as StatusLike; // need to force the type here, as it is not properly defined
}

describe('computeHashtagBarForStatus', () => {
  it('does nothing when there are no tags', () => {
    const status = createStatus('<p>Simple text</p>', []);

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Simple text</p>"`,
    );
  });

  it('displays out of band hashtags in the bar', () => {
    const status = createStatus(
      '<p>Simple text <a href="test">#hashtag</a></p>',
      ['hashtag', 'test'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual(['test']);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Simple text <a href="test">#hashtag</a></p>"`,
    );
  });

  it('extract tags from the last line', () => {
    const status = createStatus(
      '<p>Simple text</p><p><a href="test">#hashtag</a></p>',
      ['hashtag'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual(['hashtag']);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Simple text</p>"`,
    );
  });

  it('does not include tags from content', () => {
    const status = createStatus(
      '<p>Simple text with a <a href="test">#hashtag</a></p><p><a href="test">#hashtag</a></p>',
      ['hashtag'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Simple text with a <a href="test">#hashtag</a></p>"`,
    );
  });

  it('works with one line status and hashtags', () => {
    const status = createStatus(
      '<p><a href="test">#test</a>. And another <a href="test">#hashtag</a></p>',
      ['hashtag', 'test'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p><a href="test">#test</a>. And another <a href="test">#hashtag</a></p>"`,
    );
  });

  it('de-duplicate accentuated characters with case differences', () => {
    const status = createStatus(
      '<p>Text</p><p><a href="test">#éaa</a> <a href="test">#Éaa</a></p>',
      ['éaa'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual(['Éaa']);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Text</p>"`,
    );
  });

  it('does not display in bar a hashtag in content with a case difference', () => {
    const status = createStatus(
      '<p>Text <a href="test">#Éaa</a></p><p><a href="test">#éaa</a></p>',
      ['éaa'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p>Text <a href="test">#Éaa</a></p>"`,
    );
  });

  it('does not modify a status with a line of hashtags only', () => {
    const status = createStatus(
      '<p><a href="test">#test</a>  <a href="test">#hashtag</a></p>',
      ['test', 'hashtag'],
    );

    const { hashtagsInBar, statusContentProps } =
      computeHashtagBarForStatus(status);

    expect(hashtagsInBar).toEqual([]);
    expect(statusContentProps.statusContent).toMatchInlineSnapshot(
      `"<p><a href="test">#test</a>  <a href="test">#hashtag</a></p>"`,
    );
  });
});
