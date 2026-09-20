import { useTranslation } from 'react-i18next';
import type { FC } from 'react';

const FooterContent = () => {
  const { t } = useTranslation();

  return (
    <div className="flex flex-col items-center gap-3">
      <p className="inline-block flex-grow text-center text-sm text-muted-foreground lg:px-4">
        {t('footer.madeWith', { defaultValue: 'Made with 🔥 by' })}&nbsp;
        <span className="font-semibold text-red-500">Parham</span>
      </p>
    </div>
  );
};

export const Footer: FC = ({ ...props }) => {
  return (
    <div dir='ltr' className="relative w-full pb-8 pt-6 px-6" {...props}>
      <div className="container mx-auto max-w-7xl flex justify-center">
        <FooterContent />
      </div>
    </div>
  );
};
